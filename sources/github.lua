local curl = require("cURL.safe")
local json = require("cjson.safe")
local version = dofile("version.lua")

local function fetch_json(repo, request)
	local queue = {}
	local url = string.format("https://api.github.com/repos/%s/%s", repo, request)
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

local function get_version_tag(repo)
	local best_ver = "0"
	local json, err = fetch_json(repo, "tags")
	if json == nil or json.message ~= nil then
		print(json.message ~= nil and json.message or err)
		return nil
	end
	for i = 1, #json do
		local v = json[i].name
		print(v)
		if version.valid(v) then
			v = version.sanititze(v)
			if version.compare(best_ver, v) < 0 then
				best_ver = v
			end
		end
	end
	return best_ver ~= "0" and best_ver or nil
end

local function get_version_release(repo)
	local json, err = fetch_json(repo, "releases/latest")
	if json == nil then
		print(err)
		return nil
	end
	if json.tag_name ~= nil and version.valid(json.tag_name) then
		return version.sanitize(json.tag_name)
	end
	return nil
end

function get_version(repo)
	local v
	v = get_version_release(repo)
	if v ~= nil then return v end
	v = get_version_tag(repo)
	if v ~= nil then return v end
	return nil
end

--print(get_version(arg[1]))

return {
	get_version = get_version
}
