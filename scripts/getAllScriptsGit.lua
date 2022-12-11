local gitTreeUrl = "https://api.github.com/repos/mister-simon/node-computercraft-server/git/trees/cc-tweaked?recursive=1"
local gitRawUrl = "https://raw.githubusercontent.com/mister-simon/node-computercraft-server/cc-tweaked"

function getUrlContents(url)
	local http_handle = http.get(url)

	if http_handle == nil then
		print("Error getting: " .. url)
		return nil
	end

	local status = http_handle.getResponseCode()

	if status ~= 200 then
		print("Error getting: " .. url)
		print("Status code: " .. status)
		return nil
	end

	local data = http_handle.readAll()

	http_handle.close()

	return data
end

function clearScripts()
	fs.delete("scripts")
end

function main()
	local listing = getUrlContents(gitTreeUrl)
	if listing == nil then return end
	
	-- Find + parse out paths from json

	-- Clear paths

	clearRoots(listing)

	local data = ""
	local file_handle = nil

	for i=1,#listing do
		print("Getting file: "..listing[i])
		data = getUrlContents(listing[i])

		if data ~= nil then
			print("Writing file...")
			
			file_handle = fs.open(listing[i], "w");
			file_handle.write(data)
			file_handle.close()
		end

		print("")
	end
end

main()