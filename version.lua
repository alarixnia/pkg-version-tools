local function split(s)
	-- Split version into parts separated with .
	local parts = {}
	for w in s:gmatch("([^.]+)") do
		table.insert(parts, w)
	end
	return parts
end

local function strip_zeroes(s)
	while s:match("%.0$") do
		s = s:gsub("%.0$", "")
	end
	return s
end

local function compare_parts(s1, s2)
	local d1 = tonumber(s1:match("[0-9]*"))
	local d2 = tonumber(s2:match("[0-9]*"))
	if d1 ~= nil and d2 ~= nil then
		if d1 > d2 then return 1 end
		if d1 < d2 then return -1 end
	end
	if s1 > s2 then return 1 end
	if s1 < s2 then return -1 end
	return 0
end

function compare(v1, v2)
	local p1 = split(strip_zeroes(v1))
	local p2 = split(strip_zeroes(v2))
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
	local bad_matches = { "svn", "rc", "dev", "alpha", "beta", "pre" }
	for i = 1, #bad_matches do
		if v:match(bad_matches[i]) then return false end
	end
	return true
end

function sanitize(v)
	return v:gsub("[-_]", ".")
			:gsub("^[-_%a.]*", "")
			:gsub(" .*", "")
end

local function test(v1, v2, expect)
	s1 = sanitize(v1)
	s2 = sanitize(v2)
	local cmp = compare(s1, s2)
	if cmp ~= expect then print("FAIL") end
	if cmp == 0 then print(string.format("%s == %s", v1, v2))
	elseif cmp == 1 then print(string.format("%s > %s", v1, v2))
	elseif cmp == -1 then print(string.format("%s < %s", v1, v2)) end
end

local function test_run()
	test("2.80", "2.79b", 1)
	test("1.25.12", "1.25.8", 1)
	test("1.0", "1.0", 0)
	test("1.1.0.0", "1.1", 0)
	test("1.0rc1", "1.0rc2", -1)
	test("9a", "9c", -1)
	test("0.D", "0.A", 1)
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

--test_run()

return {
	valid = valid,
	compare = compare,
	sanitize = sanitize
}
