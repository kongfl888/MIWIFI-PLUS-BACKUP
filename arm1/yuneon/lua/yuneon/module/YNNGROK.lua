module ("yuneon.module.YNNGROK", package.seeall)

local YNFunction = require("yuneon.common.YNFunction")
local LuciUtil = require("luci.util")
local uci = require("luci.model.uci").cursor()

local YUNEONPATH = uci:get("yuneon", "miwifiplus", "path")

function _ngrokRestart()
	os.execute("/etc/init.d/ngrok restart")
end

function ngrokInfo()
	local list = {}
	local i = 1
	uci:foreach("ngrok", "server",
		function(s)
			local status = 0
			if s.enabled == "1" then
				local vstr = LuciUtil.exec("cat /tmp/log/ngrok.log | awk 'NR=="..i.."'")
				status = vstr:match("ok")=="ok" and 1 or 2
				i = i + 1
			end
			local item = {
				["id"] = s[".name"],
				["sname"] = s.sname,
				["lhost"] = s.lhost,
				["proto"] = s.proto,
				["shost"] = s.shost,
				["lport"] = s.lport,
				["hostname"] = s.hostname,
				["rport"] = s.rport,
				["enabled"] = s.enabled,
				["status"] = status
			}
			table.insert(list, item)
		end
	)
	return list
end

function ngrokServerGet(id)
	if YNFunction.isStrNil(id) then
		return nil
	end
	local list = {
		["id"] = id,
		["sname"] = uci:get("ngrok", id , "sname"),
		["proto"] = uci:get("ngrok", id , "proto"),
		["shost"] = uci:get("ngrok", id , "shost"),
		["lhost"] = uci:get("ngrok", id , "lhost"),
		["lport"] = uci:get("ngrok", id , "lport"),
		["hostname"] = uci:get("ngrok", id , "hostname"),
		["rport"] = uci:get("ngrok", id , "rport"),
		["enabled"] =  uci:get("ngrok", id , "enabled")
	}
	return list
end

function ngrokSet(id, sname, proto, shost, lhost, lport, hostname, rport, enabled)
	if YNFunction.isStrNil(sname) or YNFunction.isStrNil(proto) or YNFunction.isStrNil(lhost) or YNFunction.isStrNil(shost) or YNFunction.isStrNil(lport) or YNFunction.isStrNil(hostname) then
		return false
	end
	if YNFunction.isStrNil(rport) then
		rport = 0
	end
	if proto == 3 and rport == 0 then
		return false
	end
	if YNFunction.isStrNil(id) then
		id = YNFunction.strToMD5(lhost .. lport .. hostname)
	end
	local options = {
		["sname"] = sname,
		["proto"] = proto,
		["shost"] = shost,
		["lhost"] = lhost,
		["lport"] = lport,
		["hostname"] = hostname,
		["rport"] = rport,
		["enabled"] = enabled
	}
	uci:section("ngrok", "server", id, options)
	uci:commit("ngrok")
	_ngrokRestart()
	return true
end

function serverSwitch(id, enable)
    uci:set("ngrok", id, "enabled", enable)
    uci:commit("ngrok")
	_ngrokRestart()
	return true
end

function ngrokDel(id)
	uci:delete("ngrok", id)
	uci:commit("ngrok")
	_ngrokRestart()
	return true
end
