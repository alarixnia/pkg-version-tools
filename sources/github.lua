local curl = require("cURL.safe")
local json = require("cjson.safe")
local version = dofile("version.lua")

local token = os.getenv("GITHUB_TOKEN")

local function fetch_json(repo, request)
	local page_next = 0
	local header_queue = {}
	local queue = {}
	local url = string.format("https://api.github.com/repos/%s/%s", repo, request)
	local request = curl.easy()
		:setopt_customrequest("GET")
		:setopt_url(url)
		:setopt_httpheader({"Accept: application/json"})
		:setopt_httpheader({"Authorization: token " .. token})
		:setopt_httpheader({"User-Agent: pkg-version-tools"})
		:setopt_writefunction(function(buffer)
			table.insert(queue, buffer)
		end)
		:setopt_headerfunction(function(buffer)
			local match = buffer:match("page=[0-9*]")
			if match ~= nil then
				match = match:sub(6)
				if page_next == 0 then
					print(match)
					page_next = tonumber(match)
				end
			end
		end)
	request:perform()
	request:close()
	local headers = table.concat(header_queue, "")
	local output = table.concat(queue, "")
	local json, err = json.decode(output)
	return json, err, page_next
end

local function get_version_tag(best_ver, repo, page)
	local json, err, page_next = fetch_json(repo, string.format("tags?page=%d", page))
	if json == nil then
		return nil
	end
	if json.message ~= nil then
		return nil
	end
	for i = 1, #json do
		local v = json[i].name
		if version.valid(v) then
			v = version.sanitize(v)
			if version.compare(best_ver, v) < 0 then
				best_ver = v
			end
		end
	end
	if page_next > 1 then
		return get_version_tag(best_ver, repo, page_next)
	end
	return best_ver ~= "0" and best_ver or nil
end

local function get_version_release(repo)
	local json = fetch_json(repo, "releases/latest")
	if json == nil then return nil end
	if json.tag_name ~= nil and version.valid(json.tag_name) then
		return version.sanitize(json.tag_name)
	end
	return nil
end

function get_version(repo)
	local v
	v = get_version_release(repo)
	if v ~= nil then return v end
	v = get_version_tag(repo, 1)
	if v ~= nil then return v end
	return nil
end

print(get_version(arg[1]))

return {
	get_version = get_version
}
