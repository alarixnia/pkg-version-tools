local pkgsrc = dofile("sources/pkgsrc.lua")
local wikidata = dofile("sources/wikidata.lua")
local freshcode = dofile("sources/freshcode.lua")

function get_versions(pkg, sources)
		local tab = {}
		tab["pkgsrc"] = pkgsrc.get_version(pkg)
		if sources.wikidata then
			local v = wikidata.get_version(sources.wikidata)
			if v ~= nil then tab["wikidata"] = v end
		end
		if sources.freshcode then
			local v = freshcode.get_version(sources.freshcode)
			if v ~= nil then tab["freshcode"] = v end
		end
		return tab 
end

return {
	get_versions = get_versions
}
