module("luci.controller.api.yuneon", package.seeall)

function index()
	local page   = node("api","yuneon")
	page.target  = firstchild()
	page.title   = ("")
	page.order   = 100
	page.sysauth = "admin"
	page.sysauth_authenticator = "jsonauth"
	page.index = true
	entry({"api","yuneon"}, firstchild(), (""), 0)
	
	-- ADM
	entry({"api", "yuneon", "adm_get"}, call("admGet"), (""), 1)
	entry({"api", "yuneon", "adm_set"}, call("admSet"), (""), 2)
	entry({"api", "yuneon", "adm_general_get"}, call("admGeneralGet"), (""), 3)
	entry({"api", "yuneon", "adm_general_set"}, call("admGeneralSet"), (""), 4)
	entry({"api", "yuneon", "adm_cert_get"}, call("admCertGet"), (""), 5)
	entry({"api", "yuneon", "adm_rule_get"}, call("admRuleGet"), (""), 6)
	entry({"api", "yuneon", "adm_rule_set"}, call("admRuleSet"), (""), 7)
	entry({"api", "yuneon", "adm_rule_update"}, call("admRuleUpdate"), (""), 8)
    entry({"api", "yuneon", "adm_device_switch"}, call("admDeviceSwitch"), (""), 9)
	entry({"api", "yuneon", "adm_device_get"}, call("admDeviceGet"), (""), 10)
    entry({"api", "yuneon", "adm_device_set"}, call("admDeviceSet"), (""), 11)
    entry({"api", "yuneon", "adm_mac_get"}, call("admMacGet"), (""), 12)
	
	--KoolProxy
	entry({"api", "yuneon", "kp_get"}, call("kpGet"), (""), 21)
	entry({"api", "yuneon", "kp_set"}, call("kpSet"), (""), 22)
	entry({"api", "yuneon", "kp_general_get"}, call("kpGeneralGet"), (""), 23)
	entry({"api", "yuneon", "kp_general_set"}, call("kpGeneralSet"), (""), 24)
	entry({"api", "yuneon", "kp_cert_get"}, call("kpCertGet"), (""), 25)
	entry({"api", "yuneon", "kp_rule_get"}, call("kpRuleGet"), (""), 26)
	entry({"api", "yuneon", "kp_rule_set"}, call("kpRuleSet"), (""), 27)
	entry({"api", "yuneon", "kp_rule_update"}, call("kpRuleUpdate"), (""), 28)
    entry({"api", "yuneon", "kp_device_switch"}, call("kpDeviceSwitch"), (""), 29)
	entry({"api", "yuneon", "kp_device_get"}, call("kpDeviceGet"), (""), 30)
    entry({"api", "yuneon", "kp_device_set"}, call("kpDeviceSet"), (""), 31)
    entry({"api", "yuneon", "kp_mac_get"}, call("kpMacGet"), (""), 32)
	
	-- Shadowsocks
	entry({"api", "yuneon", "ss_info"}, call("ssInfo"), (""), 111)
	entry({"api", "yuneon", "ss_status"}, call("ssStatus"), (""), 112)
	entry({"api", "yuneon", "ss_switch"}, call("ssSwitch"), (""), 113)
	entry({"api", "yuneon", "ss_set"}, call("ssSet"), (""), 114)
	entry({"api", "yuneon", "ss_del"}, call("ssDel"), (""), 115)
	entry({"api", "yuneon", "ss_rule_switch"}, call("ssRuleSwitch"), (""), 116)
	entry({"api", "yuneon", "ss_rule_info"}, call("ssRuleInfo"), (""), 117)
	entry({"api", "yuneon", "ss_rule_set"}, call("ssRuleSet"), (""), 118)
	entry({"api", "yuneon", "ss_general_get"}, call("ssGeneralGet"), (""), 119)
	entry({"api", "yuneon", "ss_general_set"}, call("ssGeneralSet"), (""), 120)
	entry({"api", "yuneon", "ss_ping_get"}, call("ssPingGet"), (""), 121)
	entry({"api", "yuneon", "ss_rule_update"}, call("ssRuleUpdate"), (""), 122)
	entry({"api", "yuneon", "ss_ruledate_get"}, call("ssRuleDateGet"), (""), 123)
	entry({"api", "yuneon", "ss_conf_import"}, call("ssConfImport"), (""), 124)
    entry({"api", "yuneon", "ss_device_switch"}, call("ssDeviceSwitch"), (""), 125)
	entry({"api", "yuneon", "ss_device_get"}, call("ssDeviceGet"), (""), 126)
    entry({"api", "yuneon", "ss_device_set"}, call("ssDeviceSet"), (""), 127)
    entry({"api", "yuneon", "ss_mac_get"}, call("ssMacGet"), (""), 128)
	
	-- DDNS
	entry({"api", "yuneon", "ddns"}, call("ddnsStatus"), (""), 131)
	entry({"api", "yuneon", "ddns_switch"}, call("ddnsSwitch"), (""), 132)
	entry({"api", "yuneon", "add_server"}, call("addServer"), (""), 133)
	entry({"api", "yuneon", "del_server"}, call("deleteServer"), (""), 134)
	entry({"api", "yuneon", "server_switch"}, call("serverSwitch"), (""), 135)
	entry({"api", "yuneon", "ddns_reload"}, call("ddnsReload"), (""), 136)
	entry({"api", "yuneon", "ddns_update"}, call("ddnsUpdate"), (""), 137)
	entry({"api", "yuneon", "ddns_edit"}, call("ddnsEdit"), (""), 138)
	entry({"api", "yuneon", "get_server"}, call("getServer"), (""), 139)
	
	-- NGROK
	entry({"api", "yuneon", "ngrok_server_info"}, call("ngrokServerInfo"), (""), 151)
	entry({"api", "yuneon", "ngrok_server_get"}, call("ngrokServerGet"), (""), 152)
	entry({"api", "yuneon", "ngrok_server_set"}, call("ngrokServerSet"), (""), 153)
	entry({"api", "yuneon", "ngrok_server_del"}, call("ngrokServerDel"), (""), 154)
	entry({"api", "yuneon", "ngrok_server_switch"}, call("ngrokServerSwitch"), (""), 155)
	
	--FIERWALL
	entry({"api", "yuneon", "fw_server_info"}, call("fwServerInfo"), (""), 171)
	entry({"api", "yuneon", "fw_server_get"}, call("fwServerGet"), (""), 172)
	entry({"api", "yuneon", "fw_server_set"}, call("fwServerSet"), (""), 173)
	entry({"api", "yuneon", "fw_server_del"}, call("fwServerDel"), (""), 174)
	entry({"api", "yuneon", "fw_server_switch"}, call("fwServerSwitch"), (""), 175)
	
	
	-- webssh
	entry({"api", "yuneon", "webssh_info_get"}, call("websshInfoGet"), (""), 181)
	entry({"api", "yuneon", "webssh_switch_set"}, call("websshSwitchSet"), (""), 182)
	
	-- about
	entry({"api", "yuneon", "about_info_get"}, call("aboutInfoGet"), (""), 191)
	entry({"api", "yuneon", "about_miwifiplus_update"}, call("aboutMiwifiplusUpdate"), (""), 192)
	entry({"api", "yuneon", "about_miwifiplus_remove"}, call("aboutMiwifiplusRemove"), (""), 193)
	
end

local LuciHttp = require("luci.http")
local YNADM = require("yuneon.module.YNADM")
local YNKP = require("yuneon.module.YNKP")
local YNSS = require("yuneon.module.YNSS")
local YNDDNS = require("yuneon.module.YNDDNS")
local YNNGROK = require("yuneon.module.YNNGROK")
local YNFW = require("yuneon.module.YNFW")
local YNWEBSSH = require("yuneon.module.YNWEBSSH")
local YNABOUT = require("yuneon.module.YNABOUT")
local YNFunction = require("yuneon.common.YNFunction")
local XQErrorUtil = require("xiaoqiang.util.XQErrorUtil")

--ADM
function admSet()
	local result = {
		["code"] = 0
	}
	YNADM.admSet();
	LuciHttp.write_json(result)
end

function admGet()
	local result = {
		["code"] = 0
	}
	result = YNADM.admGet()
	LuciHttp.write_json(result)
end

function admGeneralGet()
	local result = {
		["code"] = 0
	}
	result["info"] = YNADM.generalGet()
	LuciHttp.write_json(result)
end

function admGeneralSet()
	local result = {
		["code"] = 0
	}
	local port = tonumber(LuciHttp.formvalue("port"))
	local https = tonumber(LuciHttp.formvalue("https"))
	local fltype = tonumber(LuciHttp.formvalue("fltype"))
	local extport = tonumber(LuciHttp.formvalue("extport"))
	if not port or port < 0 or port > 65535 then
		result["code"] = 1
		result["msg"] = "请输入正确的端口号（范围0~65535）！"
	end
	if result.code == 0 then
		if YNADM.generalSet(port, fltype, https, extport) then
			result["code"] = 0
		else
			result["code"] = 3
			result["msg"] = "要保存的端口已被占用！"
		end
	end
	LuciHttp.write_json(result)
end

function admCertGet()
	local result = {
		["code"] = 0
	}
	YNADM.certGet()
	LuciHttp.write_json(result)
end

function admRuleGet()
	local result = {
		["code"] = 0
	}
	result["rulelist"] = YNADM.ruleGet()
	LuciHttp.write_json(result)
end

function admRuleSet()
	local result = {
		["code"] = 0
	}
	local id = tonumber(LuciHttp.formvalue("id"))
	result["code"] = YNADM.ruleSet(id)
	LuciHttp.write_json(result)
end

function admRuleUpdate()
	local result = {
		["code"] = 0
	}
	os.execute("/etc/init.d/adm restart")
	LuciHttp.write_json(result)
end

function admDeviceGet()
    local XQDeviceUtil = require("xiaoqiang.util.XQDeviceUtil")
    local result = {
        ["code"] = 0
    }
	local info = YNADM.deviceGet()
    if info.enable == 1 then
        info["namelist"] = XQDeviceUtil.getDevicesName(info.maclist)
    end
    result["info"] = info
    LuciHttp.write_json(result)
end

function admDeviceSwitch()
    local result = {
        ["code"] = 0
    }
	YNADM.deviceSwitch()
    LuciHttp.write_json(result)
end

function admMacGet()
    local XQDeviceUtil = require("xiaoqiang.util.XQDeviceUtil")
    local result = {
        ["code"] = 0
    }
    result["list"] = XQDeviceUtil.getDeviceList(true, true)
    LuciHttp.write_json(result)
end

function admDeviceSet()
    local result = {
        ["code"] = 0
    }
    local macs = LuciHttp.formvalue("macs")
    local opt = tonumber(LuciHttp.formvalue("opt")) == 1 and 1 or 0
    if macs and opt then
        YNADM.editMac(opt, macs)
    end
    LuciHttp.write_json(result)
end

--KoolProxy
function kpSet()
	local result = {
		["code"] = 0
	}
	YNKP.kpSet();
	LuciHttp.write_json(result)
end

function kpGet()
	local result = {
		["code"] = 0
	}
	result = YNKP.kpGet()
	LuciHttp.write_json(result)
end

function kpGeneralGet()
	local result = {
		["code"] = 0
	}
	result["info"] = YNKP.generalGet()
	LuciHttp.write_json(result)
end

function kpGeneralSet()
	local result = {
		["code"] = 0
	}
	local port = tonumber(LuciHttp.formvalue("port"))
	local https = tonumber(LuciHttp.formvalue("https"))
	local fltype = tonumber(LuciHttp.formvalue("fltype"))
	local extport = tonumber(LuciHttp.formvalue("extport"))
	if not port or port < 0 or port > 65535 then
		result["code"] = 1
		result["msg"] = "请输入正确的端口号（范围0~65535）！"
	end
	if result.code == 0 then
		if YNKP.generalSet(port, fltype, https, extport) then
			result["code"] = 0
		else
			result["code"] = 3
			result["msg"] = "要保存的端口已被占用！"
		end
	end
	LuciHttp.write_json(result)
end

function kpCertGet()
	local result = {
		["code"] = 0
	}
	YNKP.certGet()
	LuciHttp.write_json(result)
end

function kpRuleGet()
	local result = {
		["code"] = 0
	}
	result["rulelist"] = YNKP.ruleGet()
	LuciHttp.write_json(result)
end

function kpRuleSet()
	local result = {
		["code"] = 0
	}
	local id = tonumber(LuciHttp.formvalue("id"))
	result["code"] = YNKP.ruleSet(id)
	LuciHttp.write_json(result)
end

function kpRuleUpdate()
	local result = {
		["code"] = 0
	}
	os.execute("/etc/init.d/kp restart")
	LuciHttp.write_json(result)
end

function kpDeviceGet()
    local XQDeviceUtil = require("xiaoqiang.util.XQDeviceUtil")
    local result = {
        ["code"] = 0
    }
	local info = YNKP.deviceGet()
    if info.enable == 1 then
        info["namelist"] = XQDeviceUtil.getDevicesName(info.maclist)
    end
    result["info"] = info
    LuciHttp.write_json(result)
end

function kpDeviceSwitch()
    local result = {
        ["code"] = 0
    }
	YNKP.deviceSwitch()
    LuciHttp.write_json(result)
end

function kpMacGet()
    local XQDeviceUtil = require("xiaoqiang.util.XQDeviceUtil")
    local result = {
        ["code"] = 0
    }
    result["list"] = XQDeviceUtil.getDeviceList(true, true)
    LuciHttp.write_json(result)
end

function kpDeviceSet()
    local result = {
        ["code"] = 0
    }
    local macs = LuciHttp.formvalue("macs")
    local opt = tonumber(LuciHttp.formvalue("opt")) == 1 and 1 or 0
    if macs and opt then
        YNKP.editMac(opt, macs)
    end
    LuciHttp.write_json(result)
end

--Shadowsocks
function ssInfo()
	local result = {}
	local info = YNSS.getSSInfo()
	local list = YNSS.getSSList()
	result["code"] = 0
	result["info"] = info
	result["list"] = list
	LuciHttp.write_json(result)
end

function ssSet()
	local result = {
		["code"] = 0
	}
	local server = LuciHttp.formvalue("server")
	local server_port = LuciHttp.formvalue("server_port")
	local password = LuciHttp.formvalue("password")
	local method = LuciHttp.formvalue("encrypt")
	local id = LuciHttp.formvalue("id")
	local server_name = LuciHttp.formvalue("server_name")
	if id then
		YNSS.ssEdit(id, server_name, server, server_port, password, method)
	else
		YNSS.ssAdd(server_name, server, server_port, password, method)
	end
	LuciHttp.write_json(result)
end

function ssDel()
	local result = {}
	local id = LuciHttp.formvalue("id")
	YNSS.ssDel(id)
	result["code"] = 0
	LuciHttp.write_json(result)
end

function ssStatus()
	local status = YNSS.ssStatus()
	local result = {}
	result["status"] = 0
	if status then
		if tonumber(status.connected) ~= 1 then
			result["status"] = 1 --未知错误
		end
		if tonumber(status.fwstatus) < 1 then
			result["status"] = 2 --防火墙配置错误
		end
		if tonumber(status.binstatus) ~= 1 then
			result["status"] = 3 --主程序未运行
		end
		if tonumber(status.enabled) ~= 1 then
			result["status"] = 4 --功能未启用
		end
	end
	result["code"] = 0
	LuciHttp.write_json(result)
end

function ssSwitch()
	local id = LuciHttp.formvalue("id")
	local conn = tonumber(LuciHttp.formvalue("conn"))
	local result = {}
    if conn and conn == 1 then
        YNSS.ssSwitch(1, id)
    else
        YNSS.ssSwitch(0, id)
    end
	result["code"] = 0
	LuciHttp.write_json(result)
end

function ssRuleSwitch()
	local result = {}
	local enable = tonumber(LuciHttp.formvalue("enable"))
	local mode = tonumber(LuciHttp.formvalue("mode"))
	YNSS.ruleSwitch(enable, mode)
	result["code"] = 0
	LuciHttp.write_json(result)
end

function ssRuleInfo()
	local result = {}
	result["info"] = YNSS.ruleInfoGet()
	result["code"] = 0
	LuciHttp.write_json(result)
end

function ssRuleSet()
	local result = {}
	local domain = LuciHttp.formvalue("domain")
	local mode = tonumber(LuciHttp.formvalue("mode"))
	local opt = tonumber(LuciHttp.formvalue("opt"))
	if YNSS.ruleSet(domain, mode, opt) then
		result["code"] = 0
	else
		result["code"] = 1
		result["msg"] = "不是域名或IP，添加失败！"
	end
	LuciHttp.write_json(result)
end

function ssGeneralGet()
	local result = {}
	result["info"] = YNSS.generalGet()
	result["code"] = 0
	LuciHttp.write_json(result)
end

function ssGeneralSet()
	local result = {
		["code"] = 0
	}
	local dnsmode = tonumber(LuciHttp.formvalue("dnsmode"))
	local localport = tonumber(LuciHttp.formvalue("localport"))
	local pacmode = tonumber(LuciHttp.formvalue("pacmode"))
	local cleandns = LuciHttp.formvalue("cleandns")
	if not localport or localport < 0 or localport > 65535 then
		result["code"] = 1
		result["msg"] = "请输入正确的端口号（范围0~65535）！"
	end
	if not YNFunction.isIPV4(cleandns) then
		result["code"] = 2
		result["msg"] = "输入的防污染DNS不是正确的IP地址！"
	end
	if result.code == 0 then
		if YNSS.generalSet(localport, cleandns, dnsmode, pacmode) then
			result["code"] = 0
		else
			result["code"] = 3
			result["msg"] = "要保存的端口已被占用！"
		end
	end
	LuciHttp.write_json(result)
end

function ssPingGet()
	local result = {
		["code"] = 0
	}
	local host = LuciHttp.formvalue("host")
	result["ping"] = YNFunction.ping(host)
	LuciHttp.write_json(result)
end

function ssRuleUpdate(pacmode)
	local result = {
		["code"] = 0
	}
	local pacmode = tonumber(LuciHttp.formvalue("pacmode"))	
	result["code"] = YNSS.ruleUpdate(pacmode)
	LuciHttp.write_json(result)
end

function ssRuleDateGet(pacmode)
	local result = {
		["code"] = 0
	}
	local pacmode = tonumber(LuciHttp.formvalue("pacmode"))
	result["date"] = YNSS.ruleDateGet(pacmode)
	LuciHttp.write_json(result)
end

function ssConfImport()
	local result = {
		["code"] = 0
	}
	local data = LuciHttp.formvalue("data")
	result.code = YNSS.confImport(data) and 0 or 1
	LuciHttp.write_json(result)
end

function ssDeviceGet()
    local XQDeviceUtil = require("xiaoqiang.util.XQDeviceUtil")
    local result = {
        ["code"] = 0
    }
	local info = YNSS.deviceGet()
    if info.enable == 1 then
        info["namelist"] = XQDeviceUtil.getDevicesName(info.maclist)
    end
    result["info"] = info
    LuciHttp.write_json(result)
end

function ssDeviceSwitch()
    local result = {
        ["code"] = 0
    }
	YNSS.deviceSwitch()
    LuciHttp.write_json(result)
end

function ssMacGet()
    local XQDeviceUtil = require("xiaoqiang.util.XQDeviceUtil")
    local result = {
        ["code"] = 0
    }
    result["list"] = XQDeviceUtil.getDeviceList(true, true)
    LuciHttp.write_json(result)
end

function ssDeviceSet()
    local result = {
        ["code"] = 0
    }
    local macs = LuciHttp.formvalue("macs")
    local opt = tonumber(LuciHttp.formvalue("opt")) == 1 and 1 or 0
    if macs and opt then
        YNSS.editMac(opt, macs)
    end
    LuciHttp.write_json(result)
end

--DDNS
function ddnsStatus()
	local XQPreference = require("xiaoqiang.XQPreference")
	local result = {
		["code"] = 0
	}
	local flag = XQPreference.get("DDNS_FLAG")
	if flag then
		result["flag"] = 0
	else
		result["flag"] = 1
		XQPreference.set("DDNS_FLAG", "1")
	end
	local ddns = YNDDNS.ddnsInfo()
	result["on"] = ddns.on
	result["list"] = ddns.list
	LuciHttp.write_json(result)
end

function ddnsSwitch()
	local result = {
		["code"] = 0
	}
	local on = tonumber(LuciHttp.formvalue("on")) == 1 and true or false
	YNDDNS.ddnsSwitch(on)
	LuciHttp.write_json(result)
end

function addServer()
	local result = {
		["code"] = 0
	}
	local serverid = tonumber(LuciHttp.formvalue("serverid"))
	local enable = tonumber(LuciHttp.formvalue("enable")) == 1 and 1 or 0
	local domain = LuciHttp.formvalue("domain") or ""
	local username = LuciHttp.formvalue("username") or ""
	local password = LuciHttp.formvalue("password") or ""
	local checkinterval = tonumber(LuciHttp.formvalue("checkinterval"))
	local forceinterval = tonumber(LuciHttp.formvalue("forceinterval"))
	if not serverid or not checkinterval or not forceinterval then
		result.code = 1612
	elseif checkinterval <= 0 or forceinterval <= 0 then
		result.code = 1523
	else
		local add = YNDDNS.setDdns(serverid, enable, username, password, checkinterval, forceinterval, domain)
		if not add then
			result.code = 1606
		end
	end
	if result.code ~= 0 then
		result["msg"] = XQErrorUtil.getErrorMessage(result.code)
	end
	LuciHttp.write_json(result)
end

function deleteServer()
	local result = {
		["code"] = 0
	}
	local id = LuciHttp.formvalue("id")
	if not id then
		result.code = 1612
	else
		local delete = YNDDNS.deleteDdns(id)
		if not delete then
			result.code = 1606
		end
	end
	if result.code ~= 0 then
		result["msg"] = XQErrorUtil.getErrorMessage(result.code)
	end
	LuciHttp.write_json(result)
end

function serverSwitch()
	local result = {
		["code"] = 0
	}
	local id = LuciHttp.formvalue("id")
	local on = tonumber(LuciHttp.formvalue("on")) == 1 and true or false
	if not id then
		result.code = 1612
	else
		local switch = YNDDNS.ddnsServerSwitch(id, on)
		if not switch then
			result.code = 1606
		end
	end
	if result.code ~= 0 then
		result["msg"] = XQErrorUtil.getErrorMessage(result.code)
	end
	LuciHttp.write_json(result)
end

function ddnsReload()
	local result = {
		["code"] = 0
	}
	if not YNDDNS.reload() then
		result.code = 1606
	end
	if result.code ~= 0 then
		result["msg"] = XQErrorUtil.getErrorMessage(result.code)
	end
	LuciHttp.write_json(result)
end

function ddnsUpdate()
	local result = {
		["code"] = 0
	}
	local id = LuciHttp.formvalue("id")
	if not YNDDNS.serverUpdate(id) then
		result.code = 1606
	end
	if result.code ~= 0 then
		result["msg"] = XQErrorUtil.getErrorMessage(result.code)
	end
	LuciHttp.write_json(result)
end

function getServer()
	local result = {}
	local id = LuciHttp.formvalue("id")
	local get = YNDDNS.getDdns(id)
	if get then
		result = get
		result["code"] = 0
	else
		result["code"] = 1614
	end
	if result.code ~= 0 then
		result["msg"] = XQErrorUtil.getErrorMessage(result.code)
	end
	LuciHttp.write_json(result)
end

function ddnsEdit()
	local result = {
		["code"] = 0
	}
	local id = LuciHttp.formvalue("id")
	local enable = tonumber(LuciHttp.formvalue("enable")) == 1 and 1 or 0
	local domain = LuciHttp.formvalue("domain")
	local username = LuciHttp.formvalue("username")
	local password = LuciHttp.formvalue("password")
	local checkinterval = tonumber(LuciHttp.formvalue("checkinterval"))
	local forceinterval = tonumber(LuciHttp.formvalue("forceinterval"))
	local edit = YNDDNS.editDdns(id, enable, username, password, checkinterval, forceinterval, domain)
	if not edit then
		result.code = 1606
	end
	if result.code ~= 0 then
		result["msg"] = XQErrorUtil.getErrorMessage(result.code)
	end
	LuciHttp.write_json(result)
end

--WEBSSH
function websshInfoGet()
	local result = {
		["code"] = 0
	}
	result["enable"] = YNWEBSSH.infoGet()
	LuciHttp.write_json(result)
end

function websshSwitchSet()
	local result = {
		["code"] = 0
	}
	YNWEBSSH.switchSet()
	LuciHttp.write_json(result)
end

--NGROK
function ngrokServerInfo()
	local result = {}
	result["code"] = 0
	result["list"] = YNNGROK.ngrokInfo()
	LuciHttp.write_json(result)
end

function ngrokServerGet()
	local result = {}
	local id = LuciHttp.formvalue("id")
	result = YNNGROK.ngrokServerGet(id)
	result["code"] = 0
	LuciHttp.write_json(result)
end

function ngrokServerSet()
	local result = {
		["code"] = 0
	}
	local id = LuciHttp.formvalue("id")
	local sname = LuciHttp.formvalue("sname")
	local proto = tonumber(LuciHttp.formvalue("proto"))
	local shost = LuciHttp.formvalue("shost")
	local lhost = LuciHttp.formvalue("lhost")
	local lport = tonumber(LuciHttp.formvalue("lport"))
	local hostname = LuciHttp.formvalue("hostname")
	local rport = tonumber(LuciHttp.formvalue("rport"))
	local enabled = tonumber(LuciHttp.formvalue("enabled"))
	YNNGROK.ngrokSet(id, sname, proto, shost, lhost, lport, hostname, rport, enabled)
	LuciHttp.write_json(result)
end

function ngrokServerDel()
	local result = {}
	local id = LuciHttp.formvalue("id")
	YNNGROK.ngrokDel(id)
	result["code"] = 0
	LuciHttp.write_json(result)
end

function ngrokServerSwitch()
	local result = {
		["code"] = 0,
		["msg"] = ""
	}
	local id = LuciHttp.formvalue("id")
	local on = tonumber(LuciHttp.formvalue("on")) == 1 and 1 or 0
	local switch = YNNGROK.serverSwitch(id, on)
	if not id then
		result.code = 1
		result.msg = "缺少ID!"
	else
		if not switch then
			result.code = 2
			result.msg = "未成功切换!"
		end
	end
	LuciHttp.write_json(result)
end

--FIREWALL
function fwServerInfo()
	local result = {}
	result["code"] = 0
	result["list"] = YNFW.fwInfo()
	LuciHttp.write_json(result)
end

function fwServerGet()
	local result = {}
	local id = LuciHttp.formvalue("id")
	result = YNFW.fwServerGet(id)
	result["code"] = 0
	LuciHttp.write_json(result)
end

function fwServerSet()
	local result = {
		["code"] = 0
	}
	local id = LuciHttp.formvalue("id")
	local name = LuciHttp.formvalue("name")
	local proto = LuciHttp.formvalue("proto")
	local dest_port = LuciHttp.formvalue("dest_port")
	local target = LuciHttp.formvalue("target")
	YNFW.fwSet(id, name, proto, dest_port, target)
	LuciHttp.write_json(result)
end

function fwServerDel()
	local result = {}
	local id = LuciHttp.formvalue("id")
	YNFW.fwDel(id)
	result["code"] = 0
	LuciHttp.write_json(result)
end

function fwServerSwitch()
	local result = {
		["code"] = 0,
		["msg"] = ""
	}
	local id = LuciHttp.formvalue("id")
	local target = LuciHttp.formvalue("target")
	local switch = YNFW.serverSwitch(id, target)
	if not id then
		result.code = 1
		result.msg = "缺少ID!"
	else
		if not switch then
			result.code = 2
			result.msg = "未成功切换!"
		end
	end
	LuciHttp.write_json(result)
end

--ABOUT
function aboutInfoGet()
	local result = {
		["code"] = 0,
		["msg"] = ""
	}
	result["curversion"] = YNABOUT.aboutInfoGet()
	LuciHttp.write_json(result)
end

function aboutMiwifiplusUpdate()

	local result = {
		["code"] = 0,
		["msg"] = ""
	}
	if not YNABOUT.aboutMiwifiplusUpdate() then
		result.code = 1
		result.msg = "升级失败，请重试！"
	end
	LuciHttp.write_json(result)
end

function aboutMiwifiplusRemove()
	local result = {
		["code"] = 0,
		["msg"] = ""
	}
	if not YNABOUT.aboutMiwifiplusRemove() then
		result.code = 1
		result.msg = "卸载失败，请重试！"
	end
	LuciHttp.write_json(result)
end

