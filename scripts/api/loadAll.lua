-- Load all of the APIs within the APIs folder
os.loadAPI("scripts/api/lib/helpers")

local apiFiles = helpers.getFiles("scripts/api")

for i=1,#apiFiles do
    pcall(function() os.loadAPI(apiFiles[i]) end)
end