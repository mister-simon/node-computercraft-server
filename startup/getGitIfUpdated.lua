local date = loadfile("startup/gitPulledAt.txt")

local commits = textutils.unserialiseJSON(
    http.get("https://api.github.com/repos/mister-simon/node-computercraft-server/commits?since="..date).fetchAll()
)

print(commits)