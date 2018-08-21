module ("yuneon.module.YNDDNS", package.seeall)

local uci = require("luci.model.uci").cursor()
local LuciUtil = require("luci.util")
local YNFunction = require("yuneon.common.YNFunction")

--- noip noip.com
--- oray 花生壳
local SERVICES = {
    ["noip"] = {
        ["service_name"] = "no-ip.com",
        ["ip_url"] = "http://[USERNAME]:[PASSWORD]@dynupdate.no-ip.com/nic/update?hostname=[DOMAIN]"
    },
    ["oray"] = {
        ["service_name"] = "oray.com",
        ["ip_url"] = "http://[USERNAME]:[PASSWORD]@ddns.oray.com:80/ph/update?hostname=[DOMAIN]"
    },
    ["pubyun"] = {
        ["service_name"] = "3322.org",
        ["ip_url"] = "http://[USERNAME]:[PASSWORD]@members.3322.net/dyndns/update?system=dyndns&hostname=[DOMAIN]"
    },
    ["dyndnsorg"] = {
        ["service_name"] = "dyndns.org",
        ["ip_url"] = "http://[USERNAME]:[PASSWORD]@members.dyndns.org/nic/update?wildcard=ON&hostname=[DOMAIN]"
    },
    ["nat123"] = {
        ["service_name"] = "nat123.com",
        ["ip_url"] = "http://[USERNAME]:[PASSWORD]@ddns.nat123.com/update.jsp?hostname=[DOMAIN]"
    },
    ["dyndnsfr"] = {
        ["service_name"] = "dyndns.fr",
        ["ip_url"] = "http://[DOMAIN]:[PASSWORD]@dyndns.dyndns.fr/update.php?hostname=[DOMAIN]"
    },
    ["dyndnspro"] = {
        ["service_name"] = "dyndnspro.com",
        ["ip_url"] = "http://[DOMAIN]:[PASSWORD]@dyndns.dyndnspro.com/update.php?hostname=[DOMAIN]"
    },
    ["dynamicdomain"] = {
        ["service_name"] = "dynamicdomain.net",
        ["ip_url"] = "http://[DOMAIN]:[PASSWORD]@dyndns.dynamicdomain.net/update.php?hostname=[DOMAIN]"
    },
    ["dyndnsit"] = {
        ["service_name"] = "dyndns.it",
        ["ip_url"] = "http://[USERNAME]:[PASSWORD]@dyndns.it/nic/update?hostname=[DOMAIN]"
    },
    ["duckdns"] = {
        ["service_name"] = "duckdns.org",
        ["ip_url"] = "http://www.duckdns.org/update?domains=[DOMAIN]&token=[PASSWORD]"
    },
    ["systemns"] = {
        ["service_name"] = "system-ns.com",
        ["ip_url"] = "http://system-ns.com/api?type=dynamic&domain=[DOMAIN]&command=set&token=[PASSWORD]"
    }
}

local ERROR = {
    ["oray"] = {
        ["notfqdn"]     = _("未有激活花生壳的域名"),
        ["badauth"]     = _("身份认证出错，请检查用户名和密码, 或者编码方式出错。"),
        ["nohost"]      = _("域名不存在或未激活花生壳"),
        ["abuse"]       = _("请求失败，频繁请求或验证失败时会出现"),
        ["!donator"]    = _("必须是付费用户才能使用此功能"),
        ["911"]         = _("花生壳系统错误")
    },
    ["pubyun"] = {
        ["badauth"]     = _("身份认证出错，请检查用户名和密码, 或者编码方式出错。"),
        ["badsys"]      = _("该域名不是动态域名，可能是其他类型的域名（智能域名、静态域名、域名转向、子域名）。"),
        ["badagent"]    = _("由于发送大量垃圾数据，客户端名称被系统封杀。"),
        ["notfqdn"]     = _("没有提供域名参数，必须提供一个在公云注册的动态域名域名。"),
        ["nohost"]      = _("域名不存在，请检查域名是否填写正确。"),
        ["!donator"]    = _("必须是收费用户，才能使用 offline 离线功能。"),
        ["!yours"]      = _("该域名存在，但是不是该用户所有。"),
        ["!active"]     = _("该域名被系统关闭，请联系公云客服人员。"),
        ["abuse"]       = _("必须是付费用户才能使用此功能"),
        ["dnserr"]      = _("DNS 服务器更新失败。"),
        ["interror"]    = _("服务器内部严重错误，比如数据库出错或者DNS服务器出错。")
    },
    ["nat123"] = {
        ["nohost"]      = _("域名不存在。指未添加动态域名解析记录，或自主域名cname/dns/ns未指向nat123解析，或解析未生效。"),
        ["badauth"]     = _("用户名密码错误。"),
        ["abuse"]       = _("请求失败，频繁请求或验证失败时会出现。"),
        ["servererror"] = _("系统错误。")
    },
    ["dyndnsorg"] = {
        ["badauth"]     = "The username and password pair do not match a real user.",
        ["numhost"]     = "Too many hosts (more than 20) specified in an update. Also returned if trying to update a round robin (which is not allowed).",
        ["good 127.0.0.1"] = "This answer indicates good update only when 127.0.0.1 address is requested by update. In all other cases it warns user that request was ignored because of agent that does not follow our specifications.",
        ["notfqdn"]     = "The hostname specified is not a fully-qualified domain name (not in the form hostname.dyndns.org or domain.com).",
        ["nohost"]      = "The hostname specified does not exist in this user account (or is not in the service specified in the system parameter).",
        ["abuse"]       = "The hostname specified is blocked for update abuse.",
        ["dnserr"]      = "DNS error encountered",
        ["911"]         = "There is a problem or scheduled maintenance on our side."
    },
    ["noip"] = {
        ["badagent"]    = "Client disabled. Client should exit and not perform any more updates without user intervention.",
        ["badauth"]     = "Invalid username password combination",
        ["nohost"]      = "Hostname supplied does not exist under specified account, client exit and require user to enter new login credentials before performing an additional request.",
        ["abuse"]       = "Username is blocked due to abuse. Either for not following our update specifications or disabled due to violation of the No-IP terms of service. Our terms of service can be viewed here. Client should stop sending updates.",
        ["!donator"]    = "An update request was sent including a feature that is not available to that particular user such as offline options.",
        ["911"]         = "A fatal error on our side such as a database outage. Retry the update no sooner than 30 minutes."
    }
}

--- id
--- 1: noip
--- 2: oray 花生壳
--- 3: 公云
--- ...
local MAP = {
    "noip",
    "oray",
    "pubyun",
    "dyndnsorg",
    "nat123",
    "dyndnsfr",
    "dyndnspro",
    "dynamicdomain",
    "dyndnsit",
    "duckdns",
    "systemns"
}

function getResult( ret, strchar, bafter)  
	local ts = string.reverse(ret)
	local param1, param2 = string.find(ts, strchar)  -- 这里以"/"为例 
	if not param1 then
		return ret
	end
	local m = string.len(ret) - param2 + 1     
	local result  
	if (bafter == true) then  
		result = string.sub(ret, m+1, string.len(ret))   
	else  
		result = string.sub(ret, 1, m-1)   
    end  
  
    return result  
end 

function _serverId(server)
    for id, ser in ipairs(MAP) do
        if ser == server then
            return id
        end
    end
    return false
end

function _ddnsRestart()
    return os.execute("/usr/sbin/ddnsd reload") == 0
end

function _ddnsServerStart(id)
	os.execute("/usr/lib/ddns/dynamic_dns_updater.sh "..id.." > /dev/null 2>&1 &")
	os.execute("sleep 1s")
	return true
end

function _ddnsServerStop(id)
	local pid = LuciUtil.exec("cat /var/run/dynamic_dns/"..id..".pid")
	if not YNFunction.isStrNil(pid) then
		os.execute("kill "..pid)
		filepath = "/var/run/dynamic_dns/"..id
		os.remove(filepath..".pid")
		os.remove(filepath..".update")
		return true
	end
	return false
end

function _ddnsServerRestart(id)
	_ddnsServerStop(id)
	os.execute("sleep 1s")
	_ddnsServerStart(id)
	return true
end

function _getUpadteUrl(service,username,password,domain)
	local updateurl = service.ip_url
    updateurl = string.gsub(updateurl,"%[USERNAME%]", username)
    updateurl = string.gsub(updateurl,"%[DOMAIN%]", domain)
    updateurl = string.gsub(updateurl,"%[PASSWORD%]", password)
	return updateurl
end

--- server: noip/oray
--- enable: 0/1
function _saveConfig(server, enable, username, password, checkinterval, forceinterval, domain)
    local service = SERVICES[server]
	local id = ""
    if service and username and password and domain and checkinterval and forceinterval then
        local section = {
			["server"] = server,
            ["enabled"] = enable,
            ["interface"] = "wan",
            ["service_name"] = service.service_name,
            ["force_interval"] = forceinterval,
            ["force_unit"] = "hours",
            ["check_interval"] = checkinterval,
            ["check_unit"] = "minutes",
            ["username"] = username,
            ["password"] = password,
            ["ip_source"] = "network",
            ["ip_url"] = _getUpadteUrl(service,username,password,domain),
            ["domain"] = domain
        }
		id = YNFunction.strToMD5(domain)
        uci:section("ddns", "service", id, section)
        uci:commit("ddns")
        return id
    end
    return id
end

function _ddnsServerSwitch(id, enable)
    uci:set("ddns", id, "enabled", enable)
    uci:commit("ddns")
    if enable == 1 then
        return _ddnsServerRestart(id)
    else
        return _ddnsServerStop(id)
    end
end

-- status: 0/1/2 error/ok/loading
function ddnsInfo()
    local result = {
        ["on"] = 0,
        ["list"] = {}
    }
	
    local LuciJson = require("cjson")
    local XQLanWanUtil = require("xiaoqiang.util.XQLanWanUtil")
    local wanip = XQLanWanUtil.getLanWanIp("wan")
    if wanip and wanip[1] then
        wanip = wanip[1].ip
    else
        wanip = ""
    end
	wanip = (string.gsub(wanip, "^%s*(.-)%s*$", "%1"))
	
    local status = LuciUtil.exec("/usr/sbin/ddnsd status")
    if not YNFunction.isStrNil(status) then
        status = LuciJson.decode(status)
        if status.daemon == "on" then
            result.on = 1
        end
        for key, value in pairs(status) do
            if key ~= "daemon" then
				local ddns = uci:get_all("ddns", key)
				local server = ddns.server
				if ddns then
					if ddns.laststatus == "ok" then
						value.status = 1
					elseif ddns.laststatus == "loading" then
						value.status = 2
					else
						value.status = 0
						local errdic = ERROR[server]
					if errdic then
						value["error"] = errdic[ddns.lastreturn] or ddns.lastreturn
					end
				end
			end
			
			value.enabled = tonumber(ddns.enabled)
			value.id = key
			value.servicename = ddns.service_name
			
			local ip_regex = [[[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}]]
			local disip = LuciUtil.exec( "echo $(nslookup '"..ddns.domain.."' 2>/dev/null) | grep -o 'Name:.*' | grep -o '"..ip_regex.."'" )
			disip = (string.gsub(disip, "^%s*(.-)%s*$", "%1"))
			if disip ~= wanip then
				value.canupdate = 1
			else
				value.canupdate = 0
			end
			value.wanip = wanip
			value.disip = disip
			table.insert(result.list, value)
            end
        end
    end
    return result
end

function ddnsSwitch(on)
    if on then
        os.execute("/usr/sbin/ddnsd start")
    else
        os.execute("/usr/sbin/ddnsd stop")
    end
end

function getDdns(id)
    if not id then
        return false
    end
    local result = {}
    local ddns = uci:get_all("ddns", id)
    if ddns then
		result["serverid"] = _serverId(ddns.server)
        result["username"] = ddns.username or ""
        result["password"] = ddns.password or ""
        result["forceinterval"] = tonumber(ddns.force_interval) or 0
        result["checkinterval"] = tonumber(ddns.check_interval) or 0
        result["domain"] = ddns.domain or ""
        result["enabled"] = tonumber(ddns.enabled) or 0
        return result
    end
    return false
end

function setDdns(serverid, enable, username, password, checkinterval, forceinterval, domain)
    if not tonumber(serverid) then
        return false
    end
    local server = MAP[tonumber(serverid)]
    if YNFunction.isStrNil(username)
        or YNFunction.isStrNil(password)
        or YNFunction.isStrNil(domain)
        or YNFunction.isStrNil(server) then
        return false
    end
    checkinterval = tonumber(checkinterval)
    forceinterval = tonumber(forceinterval)
    if not checkinterval or not forceinterval then
        return false
    end
    local denable = enable == 1 and 1 or 0
	local id = _saveConfig(server, denable, username, password, checkinterval, forceinterval, domain)
    if not YNFunction.isStrNil(id) then
        return _ddnsServerStart(id)
    end
    return false
end

function editDdns(id, enable, username, password, checkinterval, forceinterval, domain)
    if not id then
        return false
    end
    local ddns = uci:get_all("ddns", id)
	local service = SERVICES[ddns.server]
	local updateurl = service.ip_url
    if ddns then
        if not YNFunction.isStrNil(username) and username ~= ddns.username then
            uci:set("ddns", id, "username", username)
        end
        if not YNFunction.isStrNil(password) and password ~= ddns.password then
            uci:set("ddns", id, "password", password)
        end
        if not YNFunction.isStrNil(domain) and domain ~= ddns.domain then
            uci:set("ddns", id, "domain", domain)
        end
        if tonumber(checkinterval) and tonumber(checkinterval) ~= tonumber(ddns.check_interval) then
            uci:set("ddns", id, "check_interval", checkinterval)
        end
        if tonumber(forceinterval) and tonumber(forceinterval) ~= tonumber(ddns.force_interval) then
            uci:set("ddns", id, "force_interval", forceinterval)
        end
        local enabled = enable == 1 and 1 or 0
        if enabled ~= tonumber(ddns.enabled) then
            uci:set("ddns", id, "enabled", enabled)
        end
		updateurl = _getUpadteUrl(service, username, password, domain)
		uci:set("ddns", id, "ip_url", updateurl)
        uci:commit("ddns")
        if enabled ~= 0 or ddns.enabled ~= 0 then
            _ddnsServerRestart(id)
        end
        return true
    end
    return false
end

function deleteDdns(id)
    if not id then
        return false
    end
    uci:delete("ddns", id)
    uci:commit("ddns")
	_ddnsServerStop(id)
    return true
end

--- id (1/2/3...)
--- on (true/false)
function ddnsServerSwitch(id, on)
    if id then
        return _ddnsServerSwitch(id, on and 1 or 0)
    end
    return false
end

function serverUpdate(id)
	
	if not id then
		return false
	end
	
	local ddns = uci:get_all("ddns", id)
	local ret = LuciUtil.exec("curl -s '"..ddns.ip_url.."'")
		
	if not ret then
		uci:set("ddns", id, "lastretur","unknown")
		uci:set("ddns", id, "laststatus", "error")
		uci:commit("ddns")
		return false
	else
		uci:set("ddns", id, "lastreturn", ret)
		os.execute("sleep 3s")
		local ret1 = getResult(ret, " ", false)
		local ret2 = getResult(ret, " ", true) 
		if ret1 == ret2 and ret1 ~= "good" then
			uci:set("ddns", id, "laststatus", "error")
			uci:commit("ddns")
			return true
		else
			uci:set("ddns", id, "laststatus", "ok")
			uci:commit("ddns")
			return true
		end
	end
end

function reload()
    return _ddnsRestart()
end