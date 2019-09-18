local curl = require("cURL.safe")
local json = require("cjson.safe")
local version = dofile("version.lua")

local function fetch_json(repo)
	local queue = {}
	local url = string.format("https://api.github.com/repos/%s/tags", repo)
	local request = curl.easy()
		:setopt_customrequest("GET")
		:setopt_url(url)
		:setopt_httpheader({"Accept: application/json"})
		:setopt_httpheader({"User-Agent: pkg-version-tools"})
		:setopt_writefunction(function(buffer)
			table.insert(queue, buffer)
		end)
	request:perform()
	request:close()
	local output = table.concat(queue, "")
	return json.decode(output)
end

function get_version(repo)
	local json, err = fetch_json(repo)
	if json == nil then
		print(err)
		return nil
	end
	for i = 1, #json do
		local v = json[i].name
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
