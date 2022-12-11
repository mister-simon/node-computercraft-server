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
	-- Todo... How to pull all the paths from the json listing
end

function clearScripts()
	fs.delete("scripts")
end

function pullFile(url)
	print("Getting file: "..url)

	local data = getUrlContents(url)

	if data ~= nil then
		print("Writing file...")
		
		local file_handle = fs.open(url, "w");
		file_handle.write(data)
		file_handle.close()
	end

	print("")
end

function main()
	local listing = getUrlContents(gitTreeUrl)
	if listing == nil then return end
	
	-- Find + parse out paths from json
	local listingUrls = parseListing(listing)

	clearScripts(listing)

	for i=1,#listingUrls do
		pullFile(listingUrls[i])
	end
end

main()