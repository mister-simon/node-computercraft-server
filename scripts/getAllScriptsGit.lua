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

function parseListing(listing)
	local tree = textutils.unserialiseJSON(listing)["tree"]

	for i = 1, #tree do
		if tree[i]["type"] == "blob" then
			local path = tree[i]["path"]

			pullFile(gitRawUrl .. "/" .. path, path)
		end
	end
end

function clearScripts()
	fs.delete("scripts")
end

function pullFile(url, path)
	print("Getting file: \n" .. path)

	local data = getUrlContents(url)

	if data ~= nil then
		print("Writing file...")

		local file_handle = fs.open(path, "w");
		file_handle.write(data)
		file_handle.close()
	end

	print("")
end

function storeCurrentDate()
	local file_handle = fs.open("startup-gitPulledAt.txt", "w");
	file_handle.write(os.date("%Y-%m-%dT%H:%M:%SZ"))
	file_handle.close()
end

function main()
	local listing = getUrlContents(gitTreeUrl)

	if listing == nil then
		print("Listing nil'd")
		return
	end

	clearScripts()

	parseListing(listing)
	
	storeCurrentDate()
end

main()
