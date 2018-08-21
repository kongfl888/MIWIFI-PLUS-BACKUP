module ("yuneon.common.YNFunction", package.seeall)

local LuciUtil = require("luci.util")

function isStrNil(str)
	return (str == nil or str == "")
end

function macFormat(mac)
    if mac then
        return (_cmdformat(string.upper((string.gsub(mac,"-",":")))))
    else
        return ""
    end
end

function isIPV4(str)
	if str == nil or type(str) ~= "string" then
		return false
	end
	if str ~= str:match("^%d+%.%d+%.%d+%.%d+$") then
		return false
	end
	if str:match("^0") then
		return false
	end
	if str:match("%.0") then
		return false
	end

	local chunks = {str:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")}
	if (#chunks == 4) then
		for _,v in pairs(chunks) do
			if (tonumber(v) < 0 or tonumber(v) > 255) then
				return false
			end
		end
	else
		return false
	end
	return true
end

function isDomain(str)
	if str ~= str:match("^[%w%.%-]+") then
		return false
	end
	if not str:match("%.%a%a+$") then
		return false
	end
	if not str:match("^[%w]") then
		return false
	end
	if str:match("%-%-") then
		return false
	end
	if str:match("%.%.") then
		return false
	end
	if str:match("%.%-") then
		return false
	end
	if str:match("%-%.") then
		return false
	end
	return true
end

function strToMD5(str)
	return LuciUtil.trim(LuciUtil.exec("/bin/echo -n \"%s\"|/usr/bin/md5sum|/usr/bin/cut -d' ' -f1" % _cmdformat(str)))
end

function str2time(str)
	local year = string.sub(str , 1, 4)
	local month = string.sub(str , 5, 6)
	local day = string.sub(str , 7, 8)
	local hour = string.sub(str , 9, 10)
	local min = string.sub(str , 11, 12)
	local sec = string.sub(str , 13, 14)
	return os.date("%Y-%m-%d %H:%M:%S", os.time({year=year, month=month, day=day, hour=hour,min=min,sec=sec,isdst=false}))
end

function _cmdformat(str)
	if isStrNil(str) then
		return ""
	else
		return str:gsub("\\", "\\\\"):gsub("`", "\\`"):gsub("\"", "\\\""):gsub("%$", "\\$")
	end
end

function exec_table(cmd)
	local tab = {}
	local pipe = assert(io.popen(cmd),
		"exec_table(" .. cmd .. ") failed.")
	local line = pipe:read("*line")
	while line do
		table.insert(tab, line)
		line = pipe:read("*line")
	end
		pipe:close()
	return tab
end

function split(str, sep)
   local result = {}
   local regex = ("([^%s]+)"):format(sep)
   for each in str:gmatch(regex) do
	  table.insert(result, each)
   end
   return result
end

function checkhost(domain)
  local host = string.match(domain,"([%.%-%w]+)")
  if host then
	if string.len(host) == string.len(domain) then
	  return 1
	end
  end
  return nil
end

function ping(host)

	local res_ip = ""
	local res_max = -1
	local res_min = -1
	local res_avg = -1
	local res_stddev = -1
	local res_loss = -1

	local pingpart = {}
	local statpart = {}
	local tag = 1
	local ping_cmd = ""

	local code = 0
	local message = ""

	local cmd_prefix = ""

	local chkh = checkhost(host)

	if chkh then
	  ping_cmd = cmd_prefix.."ping -c1 -s32 -w20 -i0.2 -q "..host.." 2>& 1"
	else
	  code = 2
	  message = "invilad:"..host
	  return "code:"..code.."|"..message
	end

	for k, v in ipairs(exec_table(ping_cmd)) do
		local len = string.len(v)
		if len > 0 then
			if tag == 1 then
				table.insert(pingpart, v)
			else
				table.insert(statpart, v)
			end
		else
			--print("len == 0")
			tag = 0
		end
	end

	local lenppart = #pingpart
	local lenspart = #statpart

	if lenspart == 0 then
	  code = 1
	  message = pingpart[1]
	end

	if lenspart > 1 then
	  for i = 1, lenppart do
		print(pingpart[i])
		local ip = string.match(pingpart[i], "(%d+%.%d+%.%d+%.%d+)")
		if ip then
		  res_ip = ip
		end
	  end

	  for i = 2, lenspart do
		local loss = string.match(statpart[i], "([%d+%.]+)%% packet")
		if loss then
		  --print(loss)
		  res_loss = loss
		end

		local time = string.match(statpart[i], "(%d+%.%d+/%d+%.%d+/%d+%.%d+/%d+%.%d+) ms")
		if time then
		  --print(time)
		  local x = split(time, '/')
		  res_min = x[1]
		  res_avg = x[2]
		  res_max = x[3]
		  res_stddev = x[4]
		end
	  end
	  message = "DestIp:"..res_ip.."%".."Max:"..res_max.."%".."Min:"..res_min.."%".."Avg:"..res_avg.."%".."Stddev:"..res_stddev.."%".."Loss:"..res_loss
	end

	return(res_avg)
end

-- t1: table
-- t2: table
-- opt: +/- (t1 + t2)/(t1 - t2)
function merge(t1, t2, opt)
    if not t1 and not t2 then
        return nil
    end
    if opt == "+" then
        if t1 then
            if not t2 then
                return t1
            end
            local d = {}
            for _, v in ipairs(t1) do
                d[v] = true
            end
            for _, v in ipairs(t2) do
                if not d[v] then
                    table.insert(t1, v)
                end
            end
            return t1
        else
            if not t2 then
                return nil
            else
                return t2
            end
        end
    elseif opt == "-" then
        if t1 then
            if not t2 then
                return t1
            end
            local s = {}
            local d = {}
            for _, v in ipairs(t2) do
                d[v] = true
            end
            for _, v in ipairs(t1) do
                if not d[v] then
                    table.insert(s, v)
                end
            end
            return s
        end
    end
    return nil
end
