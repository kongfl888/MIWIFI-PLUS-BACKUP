module ("yuneon.module.YNFW", package.seeall)

local YNFunction = require("yuneon.common.YNFunction")
local LuciUtil = require("luci.util")
local uci = require("luci.model.uci").cursor()

function fwInfo()
	local list = {}
	uci:foreach("firewall", "rule",
		function(s)
			if s.type == "user" then
				local item = {
					["id"] = s[".name"],
					["name"] = s.name,
					["src"] = s.src,
					["proto"] = s.proto,
					["dest_port"] = s.dest_port,
					["family"] = s.family,
					["target"] = s.target
				}
				table.insert(list, item)
			end
		end
	)
	return list
end

function fwServerGet(id)
	if YNFunction.isStrNil(id) then
		return nil
	end
	local list = {
		["id"] = id,
		["name"] = uci:get("firewall", id, "name"),
		["proto"] = uci:get("firewall", id, "proto"),
		["dest_port"] = uci:get("firewall", id, "dest_port"),
		["target"] = uci:get("firewall", id, "target")
	}
	return list
end

function fwSet(id, name, proto, dest_port, target)
	if YNFunction.isStrNil(name) or YNFunction.isStrNil(proto) or YNFunction.isStrNil(dest_port) or YNFunction.isStrNil(target) then
		return false
	end
	if YNFunction.isStrNil(id) then
		id = YNFunction.strToMD5(name .. proto .. dest_port)
	else
		fwPortDel(id)
	end
	local options = {
		["type"] = "user",
		["name"] = name,
		["src"] = "wan",
		["proto"] = proto,
		["dest_port"] = dest_port,
		["family"] = "ipv4",
		["target"] = target
	}
	uci:section("firewall", "rule", id, options)
	uci:commit("firewall")
	fwPortAdd(id)
	return true
end

function serverSwitch(id, target)
	fwPortDel(id)
    uci:set("firewall", id, "target", target)
    uci:commit("firewall")
	fwPortAdd(id)
	return true
end

function fwDel(id)
	fwPortDel(id)
	uci:delete("firewall", id)
	uci:commit("firewall")
	return true
end

function fwPortDel(id)
	if YNFunction.isStrNil(id) then
		return false
	end
	local list = fwServerGet(id)
	if list.proto ~= "tcpudp" then
		return YNFunction.isStrNil(LuciUtil.exec("iptables -D zone_wan_input -p " .. list.proto .. " --dport " .. list.dest_port .. " -j " .. list.target .. " -m comment --comment '".. list.name .."'"))
	else
		local retparam1 = YNFunction.isStrNil(LuciUtil.exec("iptables -D zone_wan_input -p tcp --dport " .. list.dest_port .. " -j " .. list.target .. " -m comment --comment '".. list.name .."'"))
		local retparam2 = YNFunction.isStrNil(LuciUtil.exec("iptables -D zone_wan_input -p udp --dport " .. list.dest_port .. " -j " .. list.target .. " -m comment --comment '".. list.name .."'"))
		return retparam1 and retparam2
	end
end
function fwPortAdd(id)
	if YNFunction.isStrNil(id) then
		return false
	end
	local list = fwServerGet(id)
	local linenum = tonumber(LuciUtil.exec("iptables -L zone_wan_input|grep -c ''"))-3
	if list.proto ~= "tcpudp" then
		return YNFunction.isStrNil(LuciUtil.exec("iptables -I zone_wan_input " .. linenum .. " -p " .. list.proto .. " --dport " .. list.dest_port .. " -j " .. list.target .. " -m comment --comment '".. list.name .."'"))
	else
		local retparam1 = YNFunction.isStrNil(LuciUtil.exec("iptables -I zone_wan_input " .. linenum .. " -p tcp --dport " .. list.dest_port .. " -j " .. list.target .. " -m comment --comment '".. list.name .."'"))
		local retparam2 = YNFunction.isStrNil(LuciUtil.exec("iptables -I zone_wan_input " .. linenum .. " -p udp --dport " .. list.dest_port .. " -j " .. list.target .. " -m comment --comment '".. list.name .."'"))
		return retparam1 and retparam2
	end
end
