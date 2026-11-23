--!strict
-- Pure slice accounting for the Slice Thief. The server keeps one ledger per round.
-- Rules: one steal attempt per round; a stolen slice is recovered at most once OR lost once; never more
-- than `total` slices on the pizza; every function reports whether it changed anything so a duplicate
-- call (two players hitting at once, lag, a late callback after a restart) is a harmless no-op.
local Ledger = {}

export type State = { carried: boolean, attempted: boolean, lost: number }

function Ledger.new(): State
	return { carried = false, attempted = false, lost = 0 }
end

function Ledger.reset(l: State)
	l.carried, l.attempted, l.lost = false, false, 0
end

-- Takes one available slice off the pizza. Returns the new available count and whether it happened.
function Ledger.steal(l: State, available: number): (number, boolean)
	if l.carried or l.attempted or available <= 0 then
		return available, false
	end
	l.carried, l.attempted = true, true
	return available - 1, true
end

-- Gives exactly that slice back, once. Never exceeds `total`.
function Ledger.recover(l: State, available: number, total: number): (number, boolean)
	if not l.carried or available >= total then
		return available, false
	end
	l.carried = false
	return available + 1, true
end

-- Confirms the loss of the carried slice without touching the available count (it was already removed).
function Ledger.escape(l: State): boolean
	if not l.carried then
		return false
	end
	l.carried = false
	l.lost += 1
	return true
end

return Ledger
