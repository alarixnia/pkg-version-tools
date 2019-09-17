local version = dofile("version.lua")

local pkgsrc_dir = os.getenv("PKGSRCDIR")
pkgsrc_dir = (pkgsrc_dir == nil) and "/usr/pkgsrc" or pkgsrc_dir

local function extract_from_changes(package, file)
	local pkg_safe = package:gsub("-", "%%-")
	local added_s = string.format("\tAdded %s version ", pkg_safe)
	local added_n = #" Added " + #package + #" version "
	local updated_s = string.format("\tUpdated %s to ", pkg_safe)
	local updated_n = #" Updated " + #package + #" to "
	local f = io.open(file, "r")
	if not f then
		print("Failed to open file " .. file)
		os.exit(1)
	end
	local best_result = nil
	local line = f:read()
	while line ~= nil do
		local v = nil
		if line:match(updated_s .. "[%d%a.]* ") then
			v = line:sub(updated_n + 1)
		elseif line:match(added_s .. "[%d%a.]* ") then
			v = line:sub(added_n + 1)
		end
		if v ~= nil then
			v = v:match("[%d%a.]*")
			if not v:match("nb[%d]*$") and
				   (best_result == nil or version.compare(best_result, v) < 0) then
				best_result = v
			end
		end
		line = f:read()
	end
	io.close(f)
	return best_result
end

function get_version(package)
	local current_year = tonumber(os.date("%Y", os.time()))
	for year = current_year, 2010, -1 do
		local file = pkgsrc_dir .. string.format("/doc/CHANGES-%d", year)
		local version = extract_from_changes(package, file)
		if version ~= nil then return version end
	end
	return nil
end

--print(get_version(arg[1]))

return {
		get_version = get_version
}
