local apiPath = "scripts/api"

-- Check if there is a non-nil variable with the APIs name
local function isImported(name)
    -- Removes prefixes like "lib/movement/" etc.
    local apiVarName = string.gsub(name, ".*/", "")
    
    return loadstring("return " .. apiVarName)() ~= nil
end
    
-- Import a not yet loaded API
local function processImport(name)
    if not isImported(name) then
        os.loadAPI(apiPath .. "/" .. name .. ".lua")
    end
end

-- Import one or more scripts by name
function import(...)
    local imports = {...}

    for i=1, #imports do
        local import = string.gsub(imports[i], ".lua$", "")

        if import ~= "module" then
            processImport(import)
        end
    end
end

-- Import all the scripts in the base level of the apiPath
function importAll()
    local files = fs.list(apiPath)

    for i=1,#files do
        if not fs.isDir(apiPath .. "/" .. files[i]) then
            import(files[i])
        end
    end
end