-- Static
local maxIterations = 50
local maxIterationsError = "Error: Iterated too many times, ensure there is fuel or block / mob in the way can be destroyed"


-- Params: Int
local function checkIterations(currentIterations)
	return currentIterations == maxIterations
end


-- Params: Handler Class
function handleBlockage(handler)
	local reaction
	if handler.detect() == true then
		reaction = handler.dig
	else
		reaction = handler.attack
	end

	return unblockPath(handler.action, reaction)
end

-- Params: Function, Function
function unblockPath(action, unblockingAction)
	local iterations = 0
	while action() == false do
		unblockingAction()
		
		if checkIterations() then
			print(maxIterationsError)
			return false
		end
		iterations = iterations + 1
	end
	
	return true
end

function autoFail(handler)
	return false
end

return {
	handleBlockage = handleBlockage,
	unblockPath = unblockPath,
	autoFail = autoFail,
}