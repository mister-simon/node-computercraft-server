function ifNil(currentValue, newValue)
	if currentValue == nil then
		return newValue
	end
	
	return currentValue
end

-- Recurses over a folder to find all the files within
function getFiles(path)
    local paths = fs.list(path)
    
    local files = {}

    for i=1,#paths do
        if fs.isDir(path .. "/" .. paths[i]) then
            -- Recurse if dir
            local dirFiles = getFiles(path .. "/" .. paths[i])
            
            for k=1,#dirFiles do
                table.insert(files, dirFiles[k])
            end
        else
            -- Append to files if file
            table.insert(files, path .. "/" .. paths[i])
        end
    end

    return files
end