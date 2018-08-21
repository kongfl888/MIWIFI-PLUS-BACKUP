module ("yuneon.module.YNSS", package.seeall)

local YNFunction = require("yuneon.common.YNFunction")
local LuciUtil = require("luci.util")
local json = require("cjson")
local uci = require("luci.model.uci").cursor()

local YUNEONPATH = uci:get("yuneon", "miwifiplus", "path")
-- get SS info in /etc/config/network
function getSSInfo()
	local info = {
		id = "",
		enabled = "",
		localport = "",
		pacmode = "",
		dnsmode = ""
	}
	info.id = uci:get("yuneon", "shadowsocks", "server_id")
	info.enabled = uci:get("yuneon", "shadowsocks", "enabled")
	return info
end

-- enabled a SS config
function ssSwitch(enable, id)
	if YNFunction.isStrNil(id) then
		return false
	end
	if enable ~= 1 then
		id = 0
		enable = 0
		status = "disable"
	else
		status = "enable"
	end
	uci:set( "yuneon", "shadowsocks", "enabled", enable )
	uci:set( "yuneon", "shadowsocks", "server_id", id )
	uci:commit("yuneon")
	os.execute("/etc/init.d/shadowsocks restart")
end

-- get SS status
function ssStatus()
	local status = {
		["fwstatus"] = -1,
		['binstatus'] = -1,
		['confstatus'] = -1,
		['enabled'] = -1
	}
	local LuciUtil = require("luci.util")
	local iptable1 = LuciUtil.exec("iptables -t nat -L PREROUTING 2>/dev/null | grep -c 'SS_RULE_ENTRY'") ~= 0
	local iptable2 = LuciUtil.exec("iptables -t nat -L SS_RULE_ENTRY 2>/dev/null | grep -c 'SS_RULE_FORWARD'") ~= 0
	local iptable3 = LuciUtil.exec("iptables -t nat -L SS_RULE_FORWARD 2>/dev/null | grep -c 'redir ports'") ~= 0
	status.fwstatus = (iptable1 and iptable2 and iptable3) and 1 or 0 --1:nomarl
	status.binstatus = LuciUtil.exec("ps | grep 'ss-redir' | grep -vc 'grep'") --1:nomarl
	status.enabled = uci:get("yuneon", "shadowsocks", "enabled")
	if status.enabled == "1" then
		check1 = tonumber(LuciUtil.exec("curl --connect-timeout 5 -I -k -s -w %{http_code} https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png -o /dev/null"))
		check2 = tonumber(LuciUtil.exec("curl --connect-timeout 5 -I -k -s -w %{http_code} https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png -o /dev/null"))
		if check1 == 200 or check2 == 200 then
			status.connected = 1
		else
			status.connected = 0
		end
	end
	return status
end

-- add SS item in /etc/config/shadowsocks
function ssAdd(server_name, server, server_port, password, method)
	if YNFunction.isStrNil(server_name) or YNFunction.isStrNil(server) or YNFunction.isStrNil(server_port) or YNFunction.isStrNil(password) or YNFunction.isStrNil(method) then
		return false
	end
	local ip_regex = [[[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}]]
	local serverip = LuciUtil.exec( "echo $(nslookup '"..server.."' 2>/dev/null) | grep -o 'Name:.*' | grep -o '"..ip_regex.."' | head -1" )
	serverip = (string.gsub(serverip, "^%s*(.-)%s*$", "%1"))
	local id = YNFunction.strToMD5(serverip .. server_port)
	local options = {
		["server_name"] = server_name,
		["server"] = server,
		["server_port"] = server_port,
		["password"] = password,
		["method"] = method,
	}
	uci:section("shadowsocks", "server", id, options)
	uci:commit("shadowsocks")
	return true
end

function confImport(data)
	local data = json.decode(data)
	for _, v in pairs(data.configs) do
		if type(v) == "table" then
			ssAdd(v["remarks"], v["server"], v["server_port"], v["password"], v["method"])
		end
	end
	return true
end

-- edit a SS config in /etc/config/shadowsocks and /etc/config/network
function ssEdit(id, server_name, server, server_port, password, method)
	if YNFunction.isStrNil(id) then
		return false
	end
	uci:set("shadowsocks", id, "server", server)
	uci:set("shadowsocks", id, "server_name", server_name)
	uci:set("shadowsocks", id, "server_port", server_port)
	uci:set("shadowsocks", id, "password", password)
	uci:set("shadowsocks", id, "method", method)
	uci:commit("shadowsocks")
	return true
end

-- del a SS config in /etc/config/shadowsocks and /etc/config/network
function ssDel(id)
	uci:delete("shadowsocks", id)
	uci:commit("shadowsocks")
	if uci:get("yuneon", "shadowsocks", "server_id") == id then
		uci:set("yuneon", "shadowsocks", "server_id", "")
		uci:set("yuneon", "shadowsocks", "enabled", 0)
		os.execute("/etc/init.d/shadowsocks stop")
	end
	uci:commit("yuneon")
	return true
end

-- get shadowsocks in /etc/config/shadowsocks
function getSSList()
	local result = {}
	uci:foreach("shadowsocks", "server",
		function(s)
			local item = {
				["server_name"] = s.server_name,
				["server"] = s.server,
				["server_port"] = s.server_port,
				["password"] = s.password,
				["method"] = s.method,
				["id"] = s['.name']
			}
			table.insert(result, item)
		end
	)
	return result
end


function ruleSwitch(enable, mode)
	uci:set("yuneon", "shadowsocks", "ulist_mode", mode)
	uci:commit("yuneon")
	return true
end

function ruleInfoGet()
	local info = {}
	info.ulistmode = tonumber(uci:get("yuneon", "shadowsocks", "ulist_mode"))
	info.userlist = userListGet(info.ulistmode)
	return info
end

function generalGet()
	local info = {}
	local fs = require("nixio.fs")
	info.localport = uci:get("yuneon", "shadowsocks", "local_port")
	info.cleandns = uci:get("yuneon", "shadowsocks", "clean_dns")
	info.pacmode = uci:get("yuneon", "shadowsocks", "pac_mode")
	info.dnsmode = uci:get("yuneon", "shadowsocks", "dns_mode")
	return info
end

function ruleUpdate(pacmode)
	if pacmode == 0 then
		return os.execute(YUNEONPATH .. "/scripts/update_gfwlist")
	else
		return os.execute(YUNEONPATH .. "/scripts/update_cnlist")
	end
end

function ruleDateGet(pacmode)
	local path = ""
	local fs = require("nixio.fs")
	if pacmode == 0 then
		path = YUNEONPATH .. "/ipset/gfw_list.conf"
	else
		path = YUNEONPATH .. "/ipset/cn_list.conf"
	end
	if fs.access(path) then
		return YNFunction.str2time(LuciUtil.exec([[stat ]] .. path .. [[ | grep Modify | awk '{print $2 $3}' | cut -d"." -f1 | sed -e 's/-//g' -e 's/://g']]))
	else
		return YNFunction.str2time("19700101000000")
	end
end

function generalSet(localport, cleandns, dnsmode, pacmode)
	if tonumber(LuciUtil.exec("netstat -apn|grep -c ':"..localport.." '")) > 0 and tonumber(uci:get("yuneon", "shadowsocks", "local_port")) ~= tonumber(localport) then
		return false
	end
	uci:set("yuneon", "shadowsocks", "local_port", localport)
	uci:set("yuneon", "shadowsocks", "clean_dns", cleandns)
	uci:set("yuneon", "shadowsocks", "dns_mode", dnsmode)
	uci:set("yuneon", "shadowsocks", "pac_mode", pacmode)
	uci:commit("yuneon")
	os.execute("/etc/init.d/shadowsocks restart")
	return true
end

function ruleSet(domain, mode, opt)
	if not YNFunction.isDomain(domain) and not YNFunction.isIPV4(domain) then
		return false
	end
	userListDel(domain, mode)
	if opt == 1 then
		userListAdd(domain, mode)
	end
	os.execute("/etc/init.d/dnsmasq restart")
	return true
end

function userListGet(mode)
	local filepath = ""
	if mode == 1 then
		filepath = YUNEONPATH.."/ipset/ss_user_dst_forward.conf"
	else
		filepath = YUNEONPATH.."/ipset/ss_user_dst_drop.conf"
	end
	local fs = require("nixio.fs")
	local list = {}
	if fs.access(filepath) then
		local file = io.open(filepath, "r")
		if file then
			for line in file:lines() do
				if not YNFunction.isStrNil(line) then
					if line:match("^ipset=/%.") then
						line = line:gsub("^ipset=/%.", "")
						if mode == 1 then
							line = line:gsub("/ss_user_dst_forward$", "")
						else
							line = line:gsub("/ss_user_dst_drop$", "")
						end
						table.insert(list, line)
					end
				end
			end
		end
		file:close()
	end
	if #list > 0 then
		return list
	else
		return nil
	end
end

function userListUpdate(ulist, mode)
	if type(ulist) ~= "table" then
		return false
	end
	local filepath1 = ""
	local filepath2 = ""
	if mode == 1 then
		filepath1 = YUNEONPATH.."/ipset/ss_user_dst_forward.conf"
	else
		filepath1 = YUNEONPATH.."/ipset/ss_user_dst_drop.conf"
	end
	filepath2 = YUNEONPATH.."/ipset/ss_user_dns_list.conf"
	local file1 = io.open(filepath1, "w")
	local file2 = io.open(filepath2, "w")
	if #ulist > 0 then
		for _, line in ipairs(ulist) do
			if not YNFunction.isStrNil(line) then
				if mode == 1 then
					file1:write('ipset=/.'..line..'/ss_user_dst_forward\n')
					file2:write('server=/.'..line..'/127.0.0.1#5353\n')
				else
					file1:write('ipset=/.'..line..'/ss_user_dst_drop\n')
				end
			end
		end
	end
	file1:close()
	file2:close()
end

function userListDel(domain, mode)
	local oldlist = userListGet(mode)
	if type(oldlist) ~= "table" then
		oldlist = {
			oldlist
		}
	end
	local ulist = {}
	if #oldlist > 0 then
		for _, line in ipairs(oldlist) do
			if line ~= domain and not YNFunction.isStrNil(line) then
				table.insert(ulist, line)
			end
		end
	end
	userListUpdate(ulist, mode)
end

function userListAdd(domain, mode)
	local ulist = userListGet(mode)
	if type(ulist) ~= "table" then
		ulist = { ulist }
	end
	table.insert(ulist, domain)
	userListUpdate(ulist, mode)
end

function deviceSwitch()
	local enable = tonumber(uci:get("yuneon", "shadowsocks", "dev_enable"))
	enable = (enable == 1) and 0 or 1
	uci:set("yuneon", "shadowsocks", "dev_enable", enable)
	uci:commit("yuneon")
	os.execute("/etc/init.d/shadowsocks reload")
	return true
end

function deviceGet()
	local info = {}
	info.enable = tonumber(uci:get("yuneon", "shadowsocks", "dev_enable"))
	info.maclist = uci:get_list("yuneon", "shadowsocks", "mac")
	return info
end

-- opt: 0/1 增加/删除
function editMac(opt, macs)
	macs = LuciUtil.split(macs, ",")
	local datatypes  = require("luci.cbi.datatypes")
	if not macs or type(macs) ~= "table" then
		return false
	end
	for i, mac in ipairs(macs) do
		if YNFunction.isStrNil(mac) or not datatypes.macaddr(mac) then
			return false
		else
			macs[i] = YNFunction.macFormat(mac)
		end
	end
	local maclist = uci:get_list("yuneon", "shadowsocks", "mac")
	if maclist and type(maclist) == "table" then
		if opt == 0 then
			maclist = YNFunction.merge(maclist, macs, "+")
		else
			maclist = YNFunction.merge(maclist, macs, "-")
		end
	else
		maclist = macs
	end
	if #maclist>0 then
		uci:set("yuneon", "shadowsocks", "mac", maclist)
	else
		uci:delete("yuneon", "shadowsocks", "mac")
	end
	uci:commit("yuneon")
	os.execute("/etc/init.d/shadowsocks reload")
	return true
end
