#!/bin/sh

usage() { echo "Usage: $0 [-k <simplepush_key>] [-c <cpu_threshold>] [-m <memory_threshold>] [-d <disk_threshold>] [-f <disk_directory>] [-i <identifier>] [-e <simplepush_event>]" 1>&2; exit 0; }

while getopts ":k:c:m:d:f:i:e:" o; do
	case "${o}" in
		k)
			k=${OPTARG}
			;;
		c)
			c=${OPTARG}
			;;
		m)
			m=${OPTARG}
			;;
		d)
			d=${OPTARG}
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

if [ -z "${c}" ] && [ -z "${d}" ] && [ -z "${m}" ]; then
	echo "Nothing to do"
	return 1
fi

run () {
	if [ -n "${i}" ]; then
		if [ -n "${e}" ]; then
			eval "sh ${1} -i ${i} -e ${e}"
		else
			eval "sh ${1} -i ${i}"
		fi
	else
		if [ -n "${e}" ]; then
			eval "sh ${1} -e ${e}"
		else
			eval "sh ${1}"
		fi
	fi
}

if [ -n "${m}" ]; then
	run "memalert.sh -k ${k} -t ${m}"
fi

if [ -n "${c}" ]; then
	run "cpualert.sh -k ${k} -t ${c}"
fi

if [ -n "${d}" ] && [ -n "${f}" ]; then
	run "diskalert.sh -k ${k} -t ${d} -f ${f}"
fi
