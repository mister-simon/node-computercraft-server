local getAllScriptsFn = loadfile("scripts/getAllScripts.lua")

fs.delete("scripts")

getAllScriptsFn()