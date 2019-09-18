local lustache = require("lustache")
local packages = dofile("packages.lua")
local sources = dofile("sources.lua")
local version = dofile("version.lua")
local util = dofile("util.lua")

local package_template = [[
<tr>
<td><a href="http://pkgsrc.se/{{{name}}}">{{name}}</a></td>
{{#versions}}
{{#newest}}
<td class="new">{{version}}</td>
{{/newest}}
{{^newest}}
<td class="old"><strong>{{version}}</strong></td>
{{/newest}}
{{/versions}}
</tr>
]]

local page_template = [[
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Packaging status</title>
<style>
body {
	font-family: sans-serif;
	font-size: 18px;
	max-width: 800px;
	margin: auto;
	background-color: white;
	color: black;
}

a { color: #0000cc; }
a:visited { color: #aa00cc; }

table {
	width: 100%;
	margin-bottom: 1em;
	border-collapse: collapse;
}

th {
	text-align: left;
	font-weight: bold;
	min-width: 120px;
}

tbody tr:hover {
	background-color: #ffe10a;
}

td {
	padding-top: 3px;
	padding-bottom: 3px;
}

.old { color: #a70000; }

.new { color: #008600; }
</style>
</head>
<body>
<h1>Packaging status</h1>
<table>
<thead>
<tr>
<th>Package</th>
{{#repos}}
<th>{{name}}</th>
{{/repos}}
</tr>
</thead>
<tbody>
{{{packages}}}
</tbody>
</table>
</body>
</html>
]]

local repos = {
	{ name = "pkgsrc" },
	{ name = "wikidata" },
	{ name = "freshcode" }
}
local pkg_names = util.read_pkg_names(arg[1])
local rendered_pkgs = {}
for i = 1, #pkg_names do
	local versions = sources.get_versions(pkg_names[i], packages[pkg_names[i]])
	local highest_k = nil
	local highest_v = "0"
	for k, v in pairs(versions) do
		if version.compare(highest_v, v) < 0 then
			highest_k = k
			highest_v = v
		end
	end
	local version_data = {}
	for i = 1, #repos do
		local v = versions[repos[i].name]
		table.insert(version_data, {
			newest = (v == highest_v),
			version = v
		})
	end
	table.insert(rendered_pkgs, lustache:render(package_template, {
		name = pkg_names[i],
		versions = version_data
	}))
end
local page = {
	repos = repos,
	packages = table.concat(rendered_pkgs, "")
}
print(lustache:render(page_template, page))
