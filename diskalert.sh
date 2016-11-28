#!/bin/sh

usage() { echo "Usage: $0 [-k <simplepush_key|pushover_token>] [-t <disk_threshold>] [-f <disk_directory>] [-i <identifier>] [-e <simplepush_event>]" 1>&2; exit 0; }

while getopts ":k:t:f:i:e:" o; do
	case "${o}" in
		k)
			k=${OPTARG}
			;;
		t)
			t=${OPTARG}
			if ! ( [ "${t}" -ge 1 ] && [ "${t}" -le 100 ] ); then
				echo "<disk_threshold> must be between 1 and 100"
				return 1
			fi
			;;
		f)
			f=${OPTARG}
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

if [ -n "${t}" ] && [ -z "${f}" ]; then
	echo "Missing argument [-f <disk_directory>]"
	return 1
fi

if [ -n "${f}" ] && [ -z "${t}" ]; then
	echo "Missing argument [-d <disk_threshold>]"
	return 1
fi

key="${k}"

dir="${f}"

threshold="${t}"

usage=`df -k "${dir}" | tail -n1 | awk '{print $5}' | tr -d %`

message="${usage}%25 used"

if [ "${usage}" -gt "${threshold}" ]; then
	if [ -n "${i}" ]; then
		title="Low disk space on ${i}"
	else
		title="Low disk space"
	fi

	if [ ! -f ~/.low_disk_space_alert ]; then
		touch ~/.low_disk_space_alert

		if [ -n "${e}" ]; then
			sh send.sh "${key}" "${title}" "${message}" "${e}"
		else
			sh send.sh "${key}" "${title}" "${message}"
		fi

	fi
else
	if [ -f ~/.low_disk_space_alert ]; then
		rm ~/.low_disk_space_alert

		if [ -n "${i}" ]; then
			title="Disk space on ${i} back to normal"
		else
			title="Disk space back to normal"
		fi

		if [ -n "${e}" ]; then
			sh send.sh "${key}" "${title}" "${message}" "${e}"
		else
			sh send.sh "${key}" "${title}" "${message}"
		fi
	fi
fi
