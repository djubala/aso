#!/bin/bash

g=0
usage="Usage: ocupacio.sh [-g grup] max_permes"
# blacklisted shells
badshells=('/bin/false' '/usr/sbin/nologin' '/bin/sync')

if [ $# -eq 1 ]; then
	hmax=$1
elif [ $# -eq 3 ]; then
	if [ $1 == "-g" ]; then
		g=1
		grup=$2
		hmax=$3
	else
		echo "$usage" 1>&2; exit 1
	fi
else
	echo "$usage" 1>&2; exit 1
fi

# remove trailing B (bytes)
hmax=${hmax%B}
# convert to bytes
max=$(numfmt --from=auto --to=none $hmax)
if [ $? -ne 0 ]; then
	# TODO removed accidentally
	exit 1
fi

if [ $g -eq 1 ]; then
    grep "^$grup\>" /etc/group >/dev/null
	if [ $? -ne 0 ]; then
		echo "ocupacio.sh: $grup: Group does not exist" 1>&2; exit 1
	fi
fi

while IFS=' ' read user home shell; do
	# if -g, check that user belongs to group
	if [ $g -eq 1 ]; then
		groups $user | cut -d' ' -f3- | grep "\<$grup\>" >/dev/null
		if [ $? -ne 0 ]; then
			continue
		fi
	fi

	# check that the user is a human user (doesn't use a invalid shell)
	found=0
	for badshell in "${badshells[@]}"; do
		if [ $shell == $badshell ]; then
			found=1
			break
		fi
	done
	
	if [ $found -eq 0 ]; then
		users=("${users[@]}" "$user")
		homes=("${homes[@]}" "$home")
	fi
done < <(cut -d: -f1,6,7 --output-delimiter=' ' /etc/passwd)

total=0
for ((i=0 ; i < ${#users[@]} ; i++)); do
	user=${users[i]}
	home=${homes[i]}

	size=$(du -bs "$home" | cut -f1)
	total=$((total + size))
	hsize=$(numfmt --from=none --to=si --suffix=B $size)
	printf "  %-12s %s\n" "$user" "$hsize"

	if [ $size -ge $max ]; then
		echo "    $user exceeds max_permes"
		echo -e "\necho \"Hey $user, you are exceding the disk quota\"" >>$home/.profile
	fi
	
done

if [ $g -eq 1 ]; then
	htotal=$(numfmt --from=none --to=si --suffix=B $total)
	printf "  %-12s %s\n" "total" "$htotal"
fi

