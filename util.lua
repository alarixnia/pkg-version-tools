function read_pkg_names(file)
	file = file and file or "/dev/stdin"
	local f = io.open(file, "r")
	if f == nil then
		print(string.format("Failed to open file %s", file))
		os.exit(1)
	end

	local pkg_names = {}
	local line = f:read()
	while line ~= nil do
		if line:sub(1, 1) ~= "#" then
			table.insert(pkg_names, line)
		end
		line = f:read()
	end
	f:close()
	return pkg_names
end

return {
	read_pkg_names = read_pkg_names
}
