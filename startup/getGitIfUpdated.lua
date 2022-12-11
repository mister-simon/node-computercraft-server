local date = loadfile("startup/gitPulledAt.txt")

if date == nil then
    loadfile("scripts/getAllScriptsGit.lua")()
end

local commits = textutils.unserialiseJSON(
    http.get("https://api.github.com/repos/mister-simon/node-computercraft-server/commits?since="..date).fetchAll()
)

print(commits)