local file = fs.open("startup-sha.txt", "r")
local commit = nil
local latestCommit = nil

if (file ~= nil) then
    commit = file.readAll()
    file.close()
end

if commit == nil then
    dofile("scripts/getAllScriptsGit.lua")
end

local commits = textutils.unserialiseJSON(
    http.get("https://api.github.com/repos/mister-simon/node-computercraft-server/commits?per_page=1").readAll()
)

if (commits[1] ~= nil) then
    latestCommit = commits[1]["sha"]

    local file_handle = fs.open("startup-sha.txt", "w");
    file_handle.write(latestCommit)
    file_handle.close()
end

if (commit ~= latestCommit) then
    dofile("scripts/getAllScriptsGit.lua")
else
    print("Up to date.")
end
