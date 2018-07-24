-- Static Class Methods
-- Params: Handler Class (Context)
local function run(handler)
	local success = handler.action()
	
	if success == false then
		return handler.unblocker(handler)
	end
	
	return success
end

-- Base Class
-- Params: Function
function new(action, detect, dig, attack, unblocker)
	local handler = {}

	-- Properties
	handler.action = action
	handler.detect = detect
	handler.dig = dig
	handler.attack = attack
	handler.unblocker = unblocker
	
	-- Methods
	function handler.run() 
		return run(handler)
	end
	
	return handler;
end
