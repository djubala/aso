# Pràctica 6: Temporització de tasques

## Tasques puntuals

*Amb quina comanda es programen habitualment les tasqueas puntuals?*

S'utilitza la commanda `at`. Quan l'executem, s'ens obre un prompt on
especifiquem el job que volem. Indiquem la fi del job amb un CTRL-D. El temps
admet molts formats, repasar [aqui](https://www.computerhope.com/unix/uat.htm).
Diria que la resolució és de minuts com a màxim. L'output dels jobs s'envia als
usuaris amb el `mail` del sistema (cal estar al grup `mail`).

```
$ at now + 1 minute
warning: commands will be executed using /bin/sh
at> date >hola    
at> <EOT> 
job 3 at Thu May 21 20:48:00 2020
```

*Programeu les següents tasques:*
* *Un esborrat dels fitxers del directori /tmp a les 2 de la nit d'avui*
  Trampa! Cal esborrar també els fitxers ocults. Pero tindrem un error perque
  intentarà esborrar els directoris `.` i `..`, que no està permès. Podriem
  redireccionar l'output per a que no molesti.
```
$ at 2:00
at> rm -rf /tmp/* /tmp/.* 2>/dev/null
```

* *Fer un llistat dels usuaris connectats al servidor dintre de 10 minuts.
  Aquest llistat s'ha de deixar al home del root amb el
  nom usuaris-data.txt. On data serà la data del moment en que s'ha fet el
  llistat.* Aprofitarem la data del lab anterior. Em sembla que el `wall` no es
  veu en un terminal GUI, però si obres un tty (CTRL + F1-7) es pot veure.
```
$ at now + 10 minutes
at> who | tr -s " " | cut -d " " -f1 | sort | uniq >usuaris-$(date +%Y%m%d%H%M).txt
```

* *Un shutdown del vostre servidor al final de la classe. Volem que avisi als
  usuaris del sistema 5 minuts abans.*
```
$ at 9:55 Tue
at> wall "WARNING: shutdown at 9:00"
<...>

$ at 10:00 Tue
at> shutdown now
```

*Volem restringir aquest servei a l'usuari root.* `man at.allow` diu que podem
crear un fitxer amb els usuaris autoritzat a fer servir `at`. Hauria de
contenir només `root`.

## Tasques periòdiques

*Com podem veure quin es el contingut del cron d'un usuari?*
```bash
crontab -u USER -l
```

*Com podem afegir-hi tasques periòdiques?* Fem servir `crontab` i escrivim les
tasques (estarem borrant les existents). També podem fer servir la opció `-e`
per editar amb un editor de text (amb xuleta incorporada). El format està
explicat a `man 5 crontab`. L'exemple mostra un missatge cada 5 minuts.
```
$ crontab
* * * * * wall "hello from cron"
```

*Com podem limitar qui té accés al servei de cron?* Igual que en el `at`,
cal utilitzat `/etc/cron.allow`. Pero ojo, això resitringeix l'accés a la
commanda `crontab`, les tasques de tots els usuaris es seguiran executant.

*Que podríem fer per comprovar en el mateix moment que els nostres fitxers de
crontab són correctes? Quins efectes col·laterals tindria això*

* Podriem fer `crontab FILE`. Això valida el fitxer de crontab `FILE` i el
  carrega (eliminant el `crontab` actual).

* Quan escrivim el job per l'entrada estàndard, el `crontab` s'actualitza cada
  minut. Podriem intentar veure al `/var/log/syslog` si s'ha llegit la tasca
  correctament.

* [Crontab.guru](https://crontab.guru) et diu en quin moment s'executarà una
  tasca.

*Volem controlar l'ocupació d'una sèrie d'usuaris (fent servir l'script
ocupacio.sh que vareu fer) que estaran especificats al fitxer
/etc/ocupacio.users. El control es farà tots els diumenges. Quina entrada
afegireu al crontab? De quin usuari?*

Serà necessari l'usuari `root` per a poder inspeccionar tots els fitxers i
escriure missatges de login. Farem la comprovació a les 16:21 hores.
```
$ crontab -u root
21 16 * * sun /path/to/ocupacio.sh
``` 

*També volem controlar els usuaris innecessaris del sistema fent servir l'script
badusers.pl. Aquest control es realitzarà el primer dia de cada mes. Quina
entrada afegireu al crontab? De quin usuari? Que hem de fer perquè el llistat
d'usuaris que genera l'script ens arribi per correu?*

[Manual de mail](https://mailutils.org/manual/html_secition/mail.html). Per
poder rebre correu cal estar al grup `mail`. El programa sembla molt complicat.

*L'usuari xavim vol fer backups del seu home. Feu servir cron perquè es
compleixin les següents condicions:*
* *Es farà un backup total cada primer dilluns de mes*
* *Es farà un backup incremental tots els dimecres i dissabtes respecte al
backup total.*
* *Els backups es guardaran al mateix home de l'usuari xavim a un directori
backups. Evidentment no s'ha de fer backup dels backups.*
* *El nom dels backups ha d'incloure la data en la que es varen fer i el tipus
de backup.*
* *Per reduir l'espai que ocupen el primer dia de cada mes es comprovarà si
el tamany total dels backups és superior a 100 Mb. Si és així s'esborraran
tants backups com calgui fins estar per sota del límit en ordre cronològic
ascendent (primer els més vells).*
* *L'usuari xavim només vol rebre missatges de cron si hi ha errors.*

Muntarem un script que faci la neteja, `neteja.sh`. Els backups es dan en una
sola línia, pero els hem posat tambe dins d'un script. Ens hem d'asegurar
manualment que abans de fer un incremental existeix un total. Farem totes les
tasques al voltant de 10:10 hores. El crontab serà
així:

```crontab
10 10 1-7 * 1 /path/to/total.sh
10 15 * * 3,6 /path/to/incremental.sh
10 20 1 * * /path/to/neteja.sh
```

Respecte al tema output, el cron envia per defecte l'stdout i l'stderr. Si
nomñes volem rebre només l'stderr, cal redireccionar l'stdout cap al
`/dev/null`. En teroria aquests screipts no produeixen res cap a l'stdout, així
que no caldria fer res. Si no fos així, hauríem de redireccionar l'output des
de la línia del crontab, afegint `1>/dev/null` després del path a l'script.

