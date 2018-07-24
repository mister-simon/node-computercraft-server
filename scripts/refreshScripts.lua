local getAllScriptsFn = loadfile("scripts/getAllScripts")

local scriptsList = fs.list("scripts")

for i=1,#scriptsList do
    fs.delete(scriptsList[i])
end

getAllScriptsFn()