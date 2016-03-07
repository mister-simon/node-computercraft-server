local base_url = "https://cc-scripts.herokuapp.com/"
local listing_endpoint = "listing/lua"

function getUrlContents(endpoint)
	local http_handle = http.get(base_url .. endpoint)

	if http_handle == nil then
		print("Error getting: " .. endpoint)
		return nil
	end

	local status = http_handle.getResponseCode()

	if status ~= 200 then
		print("Error getting: " .. endpoint)
		print("Status code: " .. status)
		return nil
	end

	local data = http_handle.readAll()

	http_handle.close()

	return data
end

function clearRoots(listing)
	local roots = {}

	local match = 0
	local root = ""

	for i = 1,#listing do
		match = string.find(listing[i], "/")

		if match then
			root = string.sub(listing[i], 0, match - 1)
			roots[root] = true
		end
	end

	for root,v in ipairs(roots) do
		fs.delete(root)
	end
end

function main()
	local listing = getUrlContents(listing_endpoint)
	if listing == nil then return end
	listing = textutils.unserialise(listing)

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