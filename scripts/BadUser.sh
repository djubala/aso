#!/bin/bash

p=0
usage="Usage: BadUser.sh [-p]"
# detecció de opcions d'entrada: només son vàlids: sense paràmetres i -p
if [ $# -ne 0 ]; then
	if [ $# -eq 1 ]; then
		if [ $1 == "-p" ]; then
			p=1
		else
			echo $usage; exit 1
		fi
	else
		echo $usage; exit 1
	fi
fi

# afegiu una comanda per llegir el fitxer de password i només agafar el camp de
# nom de l'usuari
## cut amb delimiter : i seleccionem field 1
for user in `cat /etc/passwd | cut -d: -f1`; do
	## ^user\> linies que comencen per $user i final de paraula
	home=`cat /etc/passwd | grep "^$user\>" | cut -d: -f6`
	## he afegit "" perque s'em queixava amb avahi-autoipd
	if [ -d "$home" ]; then
		## -igonre_readdir_race error en proc de que el fitxer ha sigut eliminat
		num_fich=`find $home -type f -user $user | wc -l`
	else
		num_fich=0
	fi

	if [ $num_fich -eq 0 ] ; then
		if [ $p -eq 1 ]; then

# afegiu una comanda per detectar si l'usuari te processos en execució,
# si no te ningú la variable $user_proc ha de ser 0
## llista processos del usuari i compta les linies
			user_proc=`ps --no-headers -u $user | wc -l`
			
			if [ $user_proc -eq 0 ]; then
				echo "$user"
			fi
		else
			echo "$user"
		fi
	fi
done

