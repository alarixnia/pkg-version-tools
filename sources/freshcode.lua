local curl = require("cURL.safe")
local json = require("cjson.safe")
local version = dofile("version.lua")

local function fetch_json(package)
	local queue = {}
	local url = string.format("http://freshcode.club/feed/%s.json", package)
	local request = curl.easy()
		:setopt_customrequest("GET")
		:setopt_url(url)
		:setopt_httpheader({"Accept: application/json"})
		:setopt_writefunction(function(buffer)
			table.insert(queue, buffer)
		end)
	request:perform()
	request:close()
	return json.decode(table.concat(queue, ""))
end

function get_version(package)
	local json, err = fetch_json(package)
	if json == nil then
		print(err)
		return nil
	end
	for i = 1, #json.releases do
		local v = json.releases[i].version
		if (version.valid(v)) then
			return version.sanitize(v)
		end
	end
	return nil
end

--print(get_version(arg[1]))

return {
	get_version = get_version
}
