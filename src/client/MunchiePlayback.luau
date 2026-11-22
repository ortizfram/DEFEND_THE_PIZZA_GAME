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
	local actors = {}
	local function added(model)
		if model.Name ~= "Munchie" then return end
		local joints = {}
		local function add(x)
			if x:IsA("Motor6D") then joints[x]=true end
		end
		for _, x in model:GetDescendants() do add(x) end
		local connection = model.DescendantAdded:Connect(add)
		actors[model]={joints=joints,connection=connection}
	end
	arena.ChildAdded:Connect(added)
	arena.ChildRemoved:Connect(function(model)
		if actors[model] then actors[model].connection:Disconnect() actors[model]=nil end
	end)
	for _, model in arena:GetChildren() do added(model) end
	RunService.PreSimulation:Connect(function()
		local now=workspace:GetServerTimeNow()
		for model, actor in actors do
			if model:GetAttribute("Ragdolled") then continue end
			local name=model:GetAttribute("Motion")
			local elapsed=math.max(0,now-(model:GetAttribute("MotionAt") or now))
			if name=="Knockback" and elapsed>=0.5 then name="Defeat" elapsed-=0.5 end
			local clip=clips[name]
			if not clip then continue end
			local frames=clip.frames
			local duration=frames[#frames].t
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
				if name=="HitReaction" and key=="Body" then transform*=reaction(model:GetAttribute("HitKind"),elapsed) end
				joint.Transform=transform
			end
		end
	end)
end
