local function split(s)
	-- Split version into parts separated with .
	local parts = {}
	for w in s:gmatch("([^.]+)") do
		table.insert(parts, w)
	end
	return parts
end

local function compare_parts(s1, s2)
	if #s1 > #s2 then return 1 end
	if #s1 < #s2 then return -1 end
	for i = 1, #s1 do
		local c1 = s1:sub(i, i)
		local c2 = s2:sub(i, i)
		if c1 > c2 then return 1 end
		if c1 < c2 then return -1 end
	end
	return 0
end

local function test(v1, v2, expect)
	local cmp = compare(v1, v2)
	if cmp ~= expect then print("FAIL") end
	if cmp == 0 then print(string.format("%s == %s", v1, v2))
	elseif cmp == 1 then print(string.format("%s > %s", v1, v2))
	elseif cmp == -1 then print(string.format("%s < %s", v1, v2)) end
end

local function test_run()
	test("1.25.12", "1.25.8", 1)
	test("1.0", "1.0", 0)
	test("1.0rc1", "1.0rc2", -1)
	test("9a", "9c", -1)
	test("1.1.0", "1.1.1", -1)
	test("1.1.0.1", "2.1.1", -1)
	test("2.1.1", "1.1.0.1", 1)
	test("2.1.0", "1.2.4", 1)
	test("2.0.0.1", "2.0.0", 1)
	test("2.0.0", "2.0.0.1", -1)
	test("2.0.1", "2.0.1a", -1)
	test("2.0.1a", "2.0.1", 1)
	test("20.0.0", "2.0.0", 1)
end

function compare(v1, v2)
	local p1 = split(v1)
	local p2 = split(v2)
	for i = 1, #p1 do
		if i > #p2 then return 1 end
		local cmp = compare_parts(p1[i], p2[i])
		if cmp ~= 0 then return cmp end
	end
	if #p1 < #p2 then return -1 end
	return 0
end

function valid(v)
	v = v:lower()
	local bad_matches = { "svn", "rc", "dev", "alpha", "beta" }
	for i = 1, #bad_matches do
		if v:match(bad_matches[i]) then return false end
	end
	return true
end

function sanitize(v)
	if v:sub(1, 1) == "v" then
		v = v:sub(2)
	end
	return v:gsub("-", ".")
end

--test_run()

return {
	valid = valid,
	compare = compare,
	sanitize = sanitize
}
