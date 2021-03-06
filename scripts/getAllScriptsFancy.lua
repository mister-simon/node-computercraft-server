---------------------------------------------------
-- Fancy version of the getAllScripts script
--   Fancified for improved showiness when
--   used in a startup / shell.run context
---------------------------------------------------

local base_url = "https://cc-scripts.herokuapp.com/"
local listing_endpoint = "listing/lua"
local doneMessage = "WE DID IT"

local term_w, term_h = term.getSize()

local data_statuses = {}
local listing = {}

function main()
	listing = getUrlContents(listing_endpoint)
	if listing == nil then return end
	listing = textutils.unserialise(listing)

	-- table.insert(listing, 1,"cheeses/cakes/pies")
	-- table.insert(listing, 4,"cheeses/ckaes/peis")
	-- table.insert(listing, 3,"cheeses/ckeas/pies")
	-- table.insert(listing, 6,"cheeses/caeks/peis")

	clearRoots(listing)

	local listing_length = #listing

	local file_handle = nil

	local data = ""
	for i=1,listing_length do
		-- Output what's happening in a satisfying way
		printLog(i)

		-- Actually get and store the files
		data = getUrlContents(listing[i])

		if data == nil then
			data_statuses[i] = false
			printLog(i)
			sleep(1.5)
		else
			data_statuses[i] = true

			printLog(i)

			file_handle = fs.open(listing[i], "w");
			file_handle.write(data)
			file_handle.close()
		end	
	end

	fancyMessage(doneMessage)
end

-- Clears out all folders from the current listing
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

-- Fancy printing with loading bars and status messages
function printLog(current_index)
	term.clear()
	term.setCursorPos(1,1)

	for i=1,current_index do
		if data_statuses[i] ~= nil then
			if data_statuses[i] then
				print("Got File:")
			else
				print("FAILED File:")
			end
		else
			print("Getting file: ")
		end
		print(listing[i])
		print()
	end

	loadingBar(#listing / current_index)
end

-- Prepares the cursor to print out a message
function centreCursorForPrint(message)
	local msg_length = string.len(message)
	local cur_x, cur_y = term.getCursorPos()
	term.setCursorPos(math.floor((term_w - msg_length) / 2) + 1, cur_y)
end

-- Write a fancy message, centred in the console
function fancyMessage(message)
	message = " ,.-^ > "..message.." < ^-., "
	centreCursorForPrint(message)
	textutils.slowPrint(message)
end

-- Ratio should be between 0-1
function loadingBar(ratio)
	local char_pos = math.floor((term_w ) / ratio)
	local bar = string.rep(" ", char_pos)
	local bar_length = string.len(bar)

	local percent = (bar_length / term_w) * 100
	local percent_text = " " .. tostring(math.floor(percent)) .. "% "
	local percent_text_length = string.len(percent_text)

	local text_col = "7"
	if percent > 40 then text_col = "8" end
	if percent > 70 then text_col = "0" end
	if percent == 100 then text_col = "5" end

	centreCursorForPrint(bar)
	term.blit(bar, string.rep(" ", bar_length), string.rep(text_col, bar_length))


	centreCursorForPrint(percent_text)
	term.blit(percent_text, string.rep(text_col, percent_text_length), string.rep(" ", percent_text_length))
end

-- The important bit.
function getUrlContents(endpoint)
	local http_handle = http.get(base_url .. endpoint)

	if http_handle == nil then
		return nil
	end

	local status = http_handle.getResponseCode()

	if status ~= 200 then
		return nil
	end

	local data = http_handle.readAll()

	http_handle.close()

	return data
end

main()