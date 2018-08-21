#!/bin/sh
# /usr/lib/dynamic_dns/dynamic_dns_updater.sh
#
# Written by Eric Paul Bishop, Janary 2008
# Distributed under the terms of the GNU General Public License (GPL) version 2.0
#
# This script is (loosely) based on the one posted by exobyte in the forums here:
# http://forum.openwrt.org/viewtopic.php?id=14040
#

. /usr/lib/ddns/dynamic_dns_functions.sh


service_id=$1
if [ -z "$service_id" ]
then
	echo "ERRROR: You must specify a service id (the section name in the /etc/config/ddns file) to initialize dynamic DNS."
	return 1
fi
verbose_echo "service_id:$service_id"

#default mode is verbose_mode, but easily turned off with second parameter
verbose_mode="1"
if [ -n "$2" ]
then
	verbose_mode="$2"
fi

###############################################################
# Leave this comment here, to clearly document variable names
# that are expected/possible
#
# Now use load_all_config_options to load config
# options, which is a much more flexible solution.
#
#
#config_load "ddns"
#
#config_get enabled $service_id enabled
#config_get service_name $service_id service_name
#config_get update_url $service_id update_url
#
#
#config_get username $service_id username
#config_get password $service_id password
#config_get domain $service_id domain
#
#
#config_get use_https $service_id use_https
#config_get cacert $service_id cacert
#
#config_get ip_source $service_id ip_source
#config_get ip_interface $service_id ip_interface
#config_get ip_network $service_id ip_network
#config_get ip_url $service_id ip_url
#
#config_get force_interval $service_id force_interval
#config_get force_unit $service_id force_unit
#
#config_get check_interval $service_id check_interval
#config_get check_unit $service_id check_unit
#########################################################
load_all_config_options "ddns" "$service_id"


#if this service isn't enabled then quit
if [ "$enabled" != "1" ]
then
	return 0
fi

#some defaults
if [ -z "$check_interval" ]
then
	check_interval=600
fi
verbose_echo "check_interval:$check_interval"

if [ -z "$retry_interval" ]
then
	retry_interval=60
fi
verbose_echo "retry_interval:$retry_interval"

if [ -z "$check_unit" ]
then
	check_unit="seconds"
fi
verbose_echo "check_unit:$check_unit"


if [ -z "$force_interval" ]
then
	force_interval=72
fi
verbose_echo "force_interval:$force_interval"

if [ -z "$force_unit" ]
then
	force_unit="hours"
fi
verbose_echo "force_unit:$force_unit"

if [ -z "$use_https" ]
then
	use_https=0
fi
verbose_echo "use_https:$use_https"

ip_regex="[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"

NEWLINE_IFS='
'
update_url=$ip_url

#compute update interval in seconds
case "$force_unit" in
	"days" )
		force_interval_seconds=$(($force_interval*60*60*24))
		;;
	"hours" )
		force_interval_seconds=$(($force_interval*60*60))
		;;
	"minutes" )
		force_interval_seconds=$(($force_interval*60))
		;;
	"seconds" )
		force_interval_seconds=$force_interval
		;;
	* )
		#default is hours
		force_interval_seconds=$(($force_interval*60*60))
		;;
esac



#compute check interval in seconds
case "$check_unit" in
	"days" )
		check_interval_seconds=$(($check_interval*60*60*24))
		;;
	"hours" )
		check_interval_seconds=$(($check_interval*60*60))
		;;
	"minutes" )
		check_interval_seconds=$(($check_interval*60))
		;;
	"seconds" )
		check_interval_seconds=$check_interval
		;;
	* )
		#default is seconds
		check_interval_seconds=$check_interval
		;;
esac



#compute retry interval in seconds
case "$retry_unit" in
	"days" )
		retry_interval_seconds=$(($retry_interval*60*60*24))
		;;
	"hours" )
		retry_interval_seconds=$(($retry_interval*60*60))
		;;
	"minutes" )
		retry_interval_seconds=$(($retry_interval*60))
		;;
	"seconds" )
		retry_interval_seconds=$retry_interval
		;;
	* )
		#default is seconds
		retry_interval_seconds=$retry_interval
		;;
esac



verbose_echo "force seconds = $force_interval_seconds"
verbose_echo "check seconds = $check_interval_seconds"

#kill old process if it exists & set new pid file
if [ -d /var/run/dynamic_dns ]
then
	#if process is already running, stop it
	if [ -e "/var/run/dynamic_dns/$service_id.pid" ]
	then
		old_pid=$(cat /var/run/dynamic_dns/$service_id.pid)
		test_match=$(ps | grep "^[\t ]*$old_pid")
		verbose_echo "old process id (if it exists) = \"$test_match\""
		if [ -n  "$test_match" ]
		then
			kill $old_pid
		fi
	fi
else
	#make dir since it doesn't exist
	mkdir /var/run/dynamic_dns
fi
echo $$ > /var/run/dynamic_dns/$service_id.pid




#determine when the last update was
current_time=$(monotonic_time)
last_update=$(( $current_time - (2*$force_interval_seconds) ))

# here, we force update at restart
# if [ -e "/var/run/dynamic_dns/$service_id.update" ]
# then
# 	last_update=$(cat /var/run/dynamic_dns/$service_id.update)
# fi
time_since_update=$(($current_time - $last_update))

human_time_since_update=$(( $time_since_update / ( 60 * 60 ) ))
verbose_echo "time_since_update = $human_time_since_update hours"

NTPSTATUSFLAG="/tmp/ntp.status"
WAIT_MAX_CNT=10
wait_cnt=0
while [ $wait_cnt -lt $WAIT_MAX_CNT ]
do
	if [ -f $NTPSTATUSFLAG ]; then
		verbose_echo "ntp set clock successfully."
		break
	else
		wait_cnt=`expr $wait_cnt + 1`
		verbose_echo "wait ntp set clock, wait_cnt=$wait_cnt"
		sleep 10
	fi
done

#do update and then loop endlessly, checking ip every check_interval and forcing an updating once every force_interval

while [ true ]
do
	registered_ip=$(echo $(nslookup "$domain" 2>/dev/null) |  grep -o "Name:.*" | grep -o "$ip_regex")
	current_ip=$(get_current_ip)


	current_time=$(monotonic_time)
	time_since_update=$(($current_time - $last_update))


	verbose_echo "Running IP check..."
	verbose_echo "current system ip = $current_ip"
	verbose_echo "registered domain ip = $registered_ip"


	if [ "$current_ip" != "$registered_ip" ]  || [ $force_interval_seconds -lt $time_since_update ]
	then
		verbose_echo "update necessary, performing update ..."

		#do replacement

		#verbose_echo "updating with url=\"$final_url\""
		verbose_echo "updating with domain $domain"

		# performing update, set loading status
		uci set ddns.$service_id.laststatus="loading"
		uci set ddns.$service_id.lastreturn=""
		uci commit ddns

		#here we actually connect, and perform the update
		#print final_url ,containing username and password ,so that's not a good choice
		#verbose_echo "requesting $final_url"
		
		update_output=$( curl -s "$update_url" )
		if [ $? -gt 0 ]
		then
			verbose_echo "update failed, update_output:$update_output"
			uci set ddns.$service_id.laststatus="error"
			if [ -z "$update_output" ]; then
				uci set ddns.$service_id.lastreturn="network or server error"
			else
				uci set ddns.$service_id.lastreturn="$update_output"
			fi
			sleep $retry_interval_seconds
			continue
		else
			if [ -z "$update_output" ]; then
				verbose_echo "update failed, no retrun code, consider as failed."
				uci set ddns.$service_id.lastreturn="unknown"
				uci set ddns.$service_id.laststatus="error"
			else
				uci set ddns.$service_id.lastreturn="$update_output"
				prefix=${update_output% *}
				postfix=${update_output#* }
				verbose_echo "update prefix:$prefix, postfix:$postfix"
			if [ "$prefix" == "$postfix" ] && [ "$prefix" != "good" ]
			then
					verbose_echo "update failed, update_output:$update_output"
					uci set ddns.$service_id.laststatus="error"
				else
					verbose_echo "update successfully."
					if [ "$prefix" == "nochg" ]; then
						verbose_echo "update with nochg ip."
						if [ "$postfix" != "$registered_ip" ]; then
							verbose_echo "current ip diff with register ip, maybe local dns still cached!"
						fi
						uci set ddns.$service_id.laststatus="ok"
					elif [ "$prefix" == "good" ]; then
						verbose_echo "update with good ip."
						uci set ddns.$service_id.laststatus="ok"
					else
						verbose_echo "update with unknow error!"
						uci set ddns.$service_id.laststatus="error"
					fi
				fi
			fi
		fi

		uci set ddns.$service_id.lastupdate="$(date +'%Y%m%d%H%M%S')"
		uci commit ddns
		verbose_echo "update_output:$update_output"
		verbose_echo ""

		#save the time of the update
		current_time=$(monotonic_time)
		last_update=$current_time
		time_since_update='0'
		registered_ip=$current_ip

		human_time=$(date)
		verbose_echo "update complete, time is: $human_time"

		echo "$last_update" > "/var/run/dynamic_dns/$service_id.update"
	else
		human_time=$(date)
		human_time_since_update=$(( $time_since_update / ( 60 * 60 ) ))
		verbose_echo "update unnecessary"
		verbose_echo "time since last update = $human_time_since_update hours"
		verbose_echo "the time is now $human_time"
	fi

	#sleep for 10 minutes, then re-check ip && time since last update
	sleep $check_interval_seconds
done

#should never get here since we're a daemon, but I'll throw it in anyway
return 0

