module ("yuneon.module.YNADM", package.seeall)

local LuciUtil = require("luci.util")
local uci = require("luci.model.uci").cursor()
local json = require("json")
local YNFunction = require("yuneon.common.YNFunction")

local YUNEONPATH = uci:get("yuneon", "miwifiplus", "path")

function admSet()
	local enable = tonumber(uci:get("yuneon", "adm", "enabled")) == 0 and 1 or 0
	uci:set("yuneon", "adm", "enabled", enable)
	uci:commit("yuneon")
	os.execute("/etc/init.d/adm restart")
end

function admGet()
	local result = {}
	local conf = uci:get_all("yuneon", "adm")
	if conf then
		result["enabled"] = conf.enabled
	end
	local admproc = LuciUtil.exec("ps | grep 'adm' | grep -v 'grep'") ~= ""
	local iptable1 = tonumber(LuciUtil.exec("iptables -t nat -L PREROUTING 2>/dev/null | grep -c 'AD_RULE_ENTRY'")) ~= 0
	local iptable2 = tonumber(LuciUtil.exec("iptables -t nat -L AD_RULE_ENTRY 2>/dev/null | grep -c 'AD_RULE_FORWARD'")) ~= 0
	local iptable3 = tonumber(LuciUtil.exec("iptables -t nat -L AD_RULE_FORWARD 2>/dev/null | grep -c 'redir ports'")) ~= 0
	
	result["admok"] = admproc
	result["iptablesok"] = iptable1 and iptable2 and iptable3
	result["version"] = LuciUtil.exec("awk '/^[v][0-9][.][0-9]/ {print $1;exit}' ".. YUNEONPATH .."/bin/adm/version.txt"):gsub("\n","")
	return result
end

function certGet()
	local caPath = YUNEONPATH .. "/bin/adm/adm_ca.crt"
	local fs = require("nixio.fs")
	if not fs.access(caPath) then
		os.execute(YUNEONPATH .. "/bin/adm/adm /ssl rsa &>/dev/null")
	end
	local caTempPath = "/tmp/syslogbackup/adm_ca.crt"
	os.execute("mkdir /tmp/syslogbackup &>/dev/null")
	os.execute("rm -rf /tmp/syslogbackup/adm_ca.crt")
	os.execute("ln -sf "..caPath.." "..caTempPath.." &>/dev/null")
end

function generalGet()
	local result = {}
	local conf = uci:get_all("yuneon", "adm")
	if conf then
		result["fltype"] = conf.fltype
		result["extport"] = conf.extport
		result["port"] = LuciUtil.exec(YUNEONPATH .. "/scripts/ini get " .. YUNEONPATH .. "/bin/adm/ADMConfig.ini user bind_lan_port"):gsub("\n","")
		result["https"]  = LuciUtil.exec(YUNEONPATH .. "/scripts/ini get " .. YUNEONPATH .. "/bin/adm/ADMConfig.ini user support_ssl"):gsub("\n","")
	end
	return result
end

function generalSet(port, fltype, https, extport)
	if YNFunction.isStrNil(port) or YNFunction.isStrNil(fltype) or YNFunction.isStrNil(https) or YNFunction.isStrNil(extport) then
		return false
	end
	
	local curport = LuciUtil.exec(YUNEONPATH .. "/scripts/ini get " .. YUNEONPATH .. "/bin/adm/ADMConfig.ini user bind_lan_port"):gsub("\n","")
	curport = tonumber(curport)
	
	if tonumber(LuciUtil.exec("netstat -apn|grep "..port.."|wc -l")) > 0 and curport ~= port then
		return false
	end
	
	os.execute(YUNEONPATH .. "/scripts/ini set " .. YUNEONPATH .. "/bin/adm/ADMConfig.ini user bind_lan_port " .. port)
	os.execute(YUNEONPATH .. "/scripts/ini set " .. YUNEONPATH .. "/bin/adm/ADMConfig.ini user support_ssl " .. https)
	uci:set("yuneon", "adm", "fltype", fltype)
	uci:set("yuneon", "adm", "https", https)
	uci:set("yuneon", "adm", "extport", extport)
	uci:commit("yuneon")
	os.execute("/etc/init.d/adm restart")
	return true
end

function ruleGet()
	return json.decode(loadJson()).source
end

function ruleSet(id)
	local data = json.decode(loadJson())
	data.source[id].enable = data.source[id].enable == 1 and 0 or 1
	return saveJson(data)
end

function saveJson( data )
	local jsondata = json.encode( data )
	local result = 1
	local file = io.open(YUNEONPATH .. "/bin/adm/subscribe/admsubcribeV3.dat", "w")
	if file then
		file:write(jsondata)
		file:flush()
		result = 0
	end
	file:close()
	return result
end

function loadJson()
	local file = io.open(YUNEONPATH .. "/bin/adm/subscribe/admsubcribeV3.dat", "r")
	local data = {}
	if file then
		data = file:read("*a");
	end
	file:close()
	return data
end

function deviceSwitch()
	local enable = tonumber(uci:get("yuneon", "adm", "dev_enable"))
	enable = (enable == 1) and 0 or 1
	uci:set("yuneon", "adm", "dev_enable", enable)
	uci:commit("yuneon")
	os.execute("/etc/init.d/adm reload")
	return true
end

function deviceGet()
	local info = {}
	info.enable = tonumber(uci:get("yuneon", "adm", "dev_enable"))
	info.maclist = uci:get_list("yuneon", "adm", "mac")
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
	local maclist = uci:get_list("yuneon", "adm", "mac")
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
		uci:set("yuneon", "adm", "mac", maclist)
	else
		uci:delete("yuneon", "adm", "mac")
	end
	uci:commit("yuneon")
	os.execute("/etc/init.d/adm reload")
	return true
end