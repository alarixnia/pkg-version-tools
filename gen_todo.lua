local packages = dofile("packages.lua")
local sources = dofile("sources.lua")
local version = dofile("version.lua")
local util = dofile("util.lua")

local pkg_names = util.read_pkg_names(arg[1])
for i = 1, #pkg_names do
	local versions = sources.get_versions(pkg_names[i], packages[pkg_names[i]])
	local pkgsrc_v = versions["pkgsrc"]
	local highest_k = nil
	local highest_v = pkgsrc_v
	print(pkg_names[i])
	for k, v in pairs(versions) do
		print(string.format("\t%s: %s", k, v))
		if version.compare(pkgsrc_v, v) < 0 and
		   version.compare(highest_v, v) < 0 then
			highest_k = k
			highest_v = v
		end
	end
	if version.compare(pkgsrc_v, highest_v) < 0 then
		local name = pkg_names[i]:match("/[-_%a%d]*"):sub(2)
		name = name .. "-" .. highest_v
		print(string.format("pkgsrc version %s is lower than %s: %s!", pkgsrc_v, highest_k, highest_v))
		print(string.format("Adding %s to TODO!", name))
		os.execute(string.format("add_todo %s", name))
	end
end
