-- Load all of the APIs within the APIs folder
os.loadApi("scripts/api/lib/helpers")

local apiFiles = helpers.getFiles(shell.dir())

for i=1,#apiFiles do
    os.loadApi(apiFiles[i])
end