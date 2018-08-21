module ("yuneon.module.YNKP", package.seeall)

local LuciUtil = require("luci.util")
local uci = require("luci.model.uci").cursor()
local json = require("json")
local YNFunction = require("yuneon.common.YNFunction")

local YUNEONPATH = uci:get("yuneon", "miwifiplus", "path")

function kpSet()
	local enable = tonumber(uci:get("yuneon", "kp", "enabled")) == 0 and 1 or 0
	uci:set("yuneon", "kp", "enabled", enable)
	uci:commit("yuneon")
	os.execute("/etc/init.d/kp restart")
end

function kpGet()
	local result = {}
	local conf = uci:get_all("yuneon", "kp")
	if conf then
		result["enabled"] = conf.enabled
	end
	local kpproc = LuciUtil.exec("ps | grep 'bin/kp/koolproxy' | grep -v 'grep'") ~= ""
	local iptable1 = tonumber(LuciUtil.exec("iptables -t nat -L PREROUTING 2>/dev/null | grep -c 'AD_RULE_ENTRY'")) ~= 0
	local iptable2 = tonumber(LuciUtil.exec("iptables -t nat -L AD_RULE_ENTRY 2>/dev/null | grep -c 'AD_RULE_FORWARD'")) ~= 0
	local iptable3 = tonumber(LuciUtil.exec("iptables -t nat -L AD_RULE_FORWARD 2>/dev/null | grep -c 'redir ports'")) ~= 0
	
	result["kpok"] = kpproc
	result["iptablesok"] = iptable1 and iptable2 and iptable3
	result["version"] = LuciUtil.exec(YUNEONPATH .. "/bin/kp/koolproxy -v"):gsub("\n","")
	return result
end

function certGet()
	local caPath = YUNEONPATH .. "/bin/kp/data/certs/ca.crt"
	local caTempPath = "/tmp/syslogbackup/kp_ca.crt"
	os.execute("mkdir /tmp/syslogbackup &>/dev/null")
	os.execute("rm -rf /tmp/syslogbackup/kp_ca.crt")
	os.execute("ln -sf "..caPath.." "..caTempPath.." &>/dev/null")
end

function generalGet()
	local result = {}
	local conf = uci:get_all("yuneon", "kp")
	if conf then
		result["fltype"] = conf.fltype
		result["extport"] = conf.extport
		result["port"] = conf.lport
		result["https"]  = conf.https
	end
	return result
end

function generalSet(port, fltype, https, extport)
	if YNFunction.isStrNil(port) or YNFunction.isStrNil(fltype) or YNFunction.isStrNil(https) or YNFunction.isStrNil(extport) then
		return false
	end
	
	local curport = tonumber(uci:get("yuneon", "kp", "lport"))
	if tonumber(LuciUtil.exec("netstat -apn|grep :"..port.."|wc -l")) > 0 and curport ~= port then
		return false
	end
	uci:set("yuneon", "kp", "lport", port)
	uci:set("yuneon", "kp", "fltype", fltype)
	uci:set("yuneon", "kp", "https", https)
	uci:set("yuneon", "kp", "extport", extport)
	uci:commit("yuneon")
	os.execute("/etc/init.d/kp restart")
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

function deviceSwitch()
	local enable = tonumber(uci:get("yuneon", "kp", "dev_enable"))
	enable = (enable == 1) and 0 or 1
	uci:set("yuneon", "kp", "dev_enable", enable)
	uci:commit("yuneon")
	os.execute("/etc/init.d/kp reload")
	return true
end

function deviceGet()
	local info = {}
	info.enable = tonumber(uci:get("yuneon", "kp", "dev_enable"))
	info.maclist = uci:get_list("yuneon", "kp", "mac")
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
	local maclist = uci:get_list("yuneon", "kp", "mac")
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
		uci:set("yuneon", "kp", "mac", maclist)
	else
		uci:delete("yuneon", "kp", "mac")
	end
	uci:commit("yuneon")
	os.execute("/etc/init.d/kp reload")
	return true
end