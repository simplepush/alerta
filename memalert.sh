#!/bin/sh

usage() { echo "Usage: $0 [-k <simplepush_key|pushover_token>] [-t <mem_threshold>] [-i <identifier>] [-e <simplepush_event>]" 1>&2; exit 0; }

while getopts ":k:t:i:e:" o; do
	case "${o}" in
		k)
			k=${OPTARG}
			;;
		t)
			t=${OPTARG}
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

available=`free --mega -t | grep Mem | awk '{print $7}'`

if [ "${available}" -lt "${threshold}" ]; then
	if [ -n "${i}" ]; then
		title="Low memory on ${i}"
	else
		title="Low memory"
	fi

	if [ ! -f ~/.low_memory_alert ]; then
		touch ~/.low_memory_alert

		message="Available memory down to ${available} megabytes"

		if [ -n "${e}" ]; then
			sh send.sh "${key}" "${title}" "${message}" "${e}"
		else
			sh send.sh "${key}" "${title}" "${message}"
		fi
	fi
else
	if [ -f ~/.low_memory_alert ]; then
		rm ~/.low_memory_alert

		if [ -n "${i}" ]; then
			title="Available memory on ${i} back to normal"
		else
			title="Available memory back to normal"
		fi

		message="Available memory: ${available} megabytes"

		if [ -n "${e}" ]; then
			sh send.sh "${key}" "${title}" "${message}" "${e}"
		else
			sh send.sh "${key}" "${title}" "${message}"
		fi
	fi
fi
