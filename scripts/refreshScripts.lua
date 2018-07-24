local getAllScriptsFn = loadfile("scripts/getAllScripts.lua")

local scriptsList = fs.list("scripts")

for i=1,#scriptsList do
    fs.delete(scriptsList[i])
end

getAllScriptsFn()