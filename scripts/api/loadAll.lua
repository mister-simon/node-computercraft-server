-- Load all of the APIs within the APIs folder
os.loadAPI("scripts/api/lib/helpers")

local currentScript = shell.getRunningProgram()
local apiFiles = helpers.getFiles("scripts/api")

for i=1,#apiFiles do
    if apiFiles[i] ~= currentScript then
        os.loadAPI(apiFiles[i])
    end
end