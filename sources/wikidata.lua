local curl = require("cURL.safe")
local json = require("cjson.safe")
local version = dofile("version.lua")

local function fetch_json(entity)
	local queue = {}
	local url = string.format("https://www.wikidata.org/w/api.php?action=wbgetclaims&entity=%s&property=P348&format=json", entity)
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

local function get_preferred_claim(claimset)
	local best_ver = nil
	for i = 1, #claimset do
		local ver = claimset[i].mainsnak.datavalue.value
		if version.valid(ver) then
			ver = version.sanitize(ver)
			if best_ver == nil or version.compare(best_ver, ver) < 0 then
				best_ver = ver
			end
		end
	end
	return best_ver
end

function get_version(entity)
	local json, err = fetch_json(entity)
	if json == nil then
		print(err)
		return nil
	end
	local pref = get_preferred_claim(json.claims.P348);
	if pref == nil then
		-- return the last value if none is preferred
		return version.sanitize(json.claims.P348[#json.claims.P348].mainsnak.datavalue.value)
	end
	return pref
end

--print(get_version(arg[1]))

return {
	get_version = get_version
}
