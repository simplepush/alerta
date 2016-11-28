#!/bin/sh

usage() { echo "Usage: $0 [-k <simplepush_key|pushover_token>] [-t <cpu_threshold>] [-i <identifier>] [-e <simplepush_event>]" 1>&2; exit 0; }

while getopts ":k:t:i:e:" o; do
	case "${o}" in
		k)
			k=${OPTARG}
			;;
		t)
			t=${OPTARG}
			if ! ( [ "${t}" -ge 1 ] && [ "${t}" -le 100 ] ); then
				echo "<cpu_threshold> must be between 1 and 100"
				return 1
			fi
			;;
		i)
			i=${OPTARG}
			;;
		e)
			e=${OPTARG}
			;;
		*)
			usage
			;;
	esac
done
shift $((OPTIND-1))

if [ -z "${t}" ]; then
	echo "Missing argument [-t <cpu_threshold>]"
	return 1
fi

key="${k}"

threshold="${t}"

usage=$((100-$(vmstat 5 2|tail -1|awk '{print $15}')))

message="CPU usage is ${usage}%25"

if [ "${usage}" -ge "${threshold}" ]; then
	if [ -n "${i}" ]; then
		title="High CPU usage on ${i}"
	else
		title="High CPU usage"
	fi

	if [ ! -f ~/.high_cpu_usage_alert ]; then
		touch ~/.high_cpu_usage_alert

		if [ -n "${e}" ]; then
			sh send.sh "${key}" "${title}" "${message}" "${e}"
		else
			sh send.sh "${key}" "${title}" "${message}"
		fi
	fi
else
	if [ -f ~/.high_cpu_usage_alert ]; then
		rm ~/.high_cpu_usage_alert

		if [ -n "${i}" ]; then
			title="CPU usage on ${i} back to normal"
		else
			title="CPU usage back to normal"
		fi

		if [ -n "${e}" ]; then
			sh send.sh "${key}" "${title}" "${message}" "${e}"
		else
			sh send.sh "${key}" "${title}" "${message}"
		fi
	fi
fi
