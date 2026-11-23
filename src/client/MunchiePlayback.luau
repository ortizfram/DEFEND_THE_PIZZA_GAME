-- Visual playback of the authored blockout poses. Game rules run on the server.
local RunService = game:GetService("RunService")
-- Extra body reaction on top of the HitReaction clip, by swing kind (1 overhead, 2 uppercut, 3 side).
local function reaction(kind, elapsed)
	local e = math.max(0, 1 - elapsed / 0.32)
	e *= e
	if kind == 1 then
		return CFrame.new(0, -0.55 * e, 0) * CFrame.Angles(math.rad(-18 * e), 0, 0) -- squashed into the floor
	elseif kind == 2 then
		return CFrame.Angles(math.rad(38 * e), 0, 0) -- popped up and back
	elseif kind == 3 then
		return CFrame.Angles(0, math.rad(35 * e), math.rad(26 * e)) -- spun and rolled sideways
	end
	return CFrame.identity
end

local function readClips(folder)
	local clips = {}
	for _, seq in folder:GetChildren() do
		if not seq:IsA("KeyframeSequence") then continue end
		local frames = {}
		for _, key in seq:GetKeyframes() do
			local poses = {}
			for _, p in key:GetDescendants() do
				if p:IsA("Pose") then poses[p.Name] = p.CFrame end
			end
			if next(poses) then table.insert(frames,{t=key.Time,poses=poses}) end
		end
		table.sort(frames,function(a,b) return a.t < b.t end)
		if #frames > 0 then clips[seq.Name] = {frames=frames,loop=seq.Loop} end
	end
	return clips
end

return function(folder, arena)
	local clips = readClips(folder)
	-- Arm pose while the Slice Thief carries a slice over its hat (Config.P0.Thief.CarryPose, replicated as JSON).
	local carryPose = {}
	local function loadCarryPose()
		local ok, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(folder:GetAttribute("CarryPose") or "{}") end)
		table.clear(carryPose)
		if ok then
			for key, a in decoded do carryPose[key] = CFrame.Angles(math.rad(a[1]), math.rad(a[2]), math.rad(a[3])) end
		end
	end
	loadCarryPose()
	folder:GetAttributeChangedSignal("CarryPose"):Connect(loadCarryPose)
	local actors = {}
	local function added(model)
		if model.Name ~= "Munchie" then return end
		local joints = {}
		local function add(x)
			if x:IsA("Motor6D") then joints[x]=true end
		end
		for _, x in model:GetDescendants() do add(x) end
		local connection = model.DescendantAdded:Connect(add)
		actors[model]={joints=joints,connection=connection,current={},from={},signature="",carry=0}
	end
	arena.ChildAdded:Connect(added)
	arena.ChildRemoved:Connect(function(model)
		if actors[model] then actors[model].connection:Disconnect() actors[model]=nil end
	end)
	for _, model in arena:GetChildren() do added(model) end
	-- Walk is paced by Config.P0.Walk (replicated on the clips folder): Rate scales playback speed and Stride
	-- scales the leg swing, so planted feet match the real MunchieSpeed instead of sliding.
	local FADE = 0.15 -- seconds of cross-fade between clips
	local FINISHED_TO_IDLE = { PizzaBite = true, HitReaction = true } -- one-shot clips hand over to Idle, never freeze
	RunService.PreSimulation:Connect(function()
		local now=workspace:GetServerTimeNow()
		local clock=os.clock()
		local walkRate=folder:GetAttribute("WalkRate") or 1
		local stride=folder:GetAttribute("WalkStride") or 1
		for model, actor in actors do
			if model:GetAttribute("Ragdolled") then continue end -- ragdoll keeps the last pose and physics takes over
			local name=model:GetAttribute("Motion")
			local startedAt=model:GetAttribute("MotionAt") or now
			local elapsed=math.max(0,now-startedAt)
			if name=="Knockback" and elapsed>=0.5 then name="Defeat" elapsed-=0.5 end
			local clip=clips[name]
			if not clip then continue end
			local frames=clip.frames
			local duration=frames[#frames].t
			local isWalk=name=="Walk"
			if isWalk then elapsed*=walkRate*(model:GetAttribute("GaitMul") or 1) end
			if not clip.loop and FINISHED_TO_IDLE[name] and elapsed>duration and clips.Idle then
				elapsed-=duration
				name,clip,isWalk="Idle",clips.Idle,false
				frames=clip.frames
				duration=frames[#frames].t
			end
			local signature=name..startedAt
			if actor.signature~=signature then
				actor.signature=signature
				actor.from=table.clone(actor.current)
				actor.fadeAt=clock
			end
			local fade=if actor.fadeAt then math.clamp((clock-actor.fadeAt)/FADE,0,1) else 1
			-- Arms rise/lower over 0.25 s when the thief picks up / drops the slice.
			local carryStep=math.min(clock-(actor.clock or clock),0.1)/0.25
			actor.clock=clock
			actor.carry=if model:GetAttribute("CarryAt")~=nil then math.min(1,actor.carry+carryStep) else math.max(0,actor.carry-carryStep)
			if clip.loop and duration>0 then elapsed%=duration end
			local left,right=frames[#frames],frames[#frames]
			for i=2,#frames do
				if elapsed<=frames[i].t then left,right=frames[i-1],frames[i] break end
			end
			local alpha=if right==left then 0 else math.clamp((elapsed-left.t)/(right.t-left.t),0,1)
			for joint in actor.joints do
				if not joint.Part1 then continue end
				local key=joint.Part1.Name
				local transform=(left.poses[key] or CFrame.identity):Lerp(right.poses[key] or CFrame.identity,alpha)
				if isWalk and stride~=1 and (key=="RightLeg" or key=="LeftLeg") then
					local axis,angle=transform:ToAxisAngle()
					if angle~=0 then transform=CFrame.fromAxisAngle(axis,angle*stride) end
				end
				if name=="HitReaction" and key=="Body" then transform*=reaction(model:GetAttribute("HitKind"),elapsed) end
				if actor.carry>0 and carryPose[key] then transform=transform:Lerp(carryPose[key],actor.carry) end
				-- Head stays level while carrying so the hat (and the slice on it) keeps a constant gap to the raised hands.
				if actor.carry>0 and key=="Head" then transform=transform:Lerp(CFrame.identity,actor.carry) end
				if fade<1 and actor.from[joint] then transform=actor.from[joint]:Lerp(transform,fade) end
				actor.current[joint]=transform
				joint.Transform=transform
			end
		end
	end)
end
