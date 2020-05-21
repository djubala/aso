# Pràctica 6: Temporització de tasques

## Tasques puntuals

*Amb quina comanda es programen habitualment les tasqueas puntuals?*

S'utilitza la commanda `at`. Quan l'executem, s'ens obre un prompt on
especifiquem el job que volem. Indiquem la fi del job amb un CTRL-D. El temps
admet molts formats, repasar [aqui](https://www.computerhope.com/unix/uat.htm).
Diria que la resolució és de minuts com a màxim. L'output dels jobs s'envia als
usuaris amb el `mail` del sistema (cal estar al grup `mail`).

```bash
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
```bash
$ at 2:00
at> rm -rf /tmp/* /tmp/.* 2>/dev/null
```

* *Fer un llistat dels usuaris connectats al servidor dintre de 10 minuts.
  Aquest llistat s'ha de deixar al home del root amb el
  nom usuaris-data.txt. On data serà la data del moment en que s'ha fet el
  llistat.* Aprofitarem la data del lab anterior. Em sembla que el `wall` no es
  veu en un terminal GUI, però si obres un tty (CTRL + F1-7) es pot veure.
```bash
$ at now + 10 minutes
at> who | tr -s " " | cut -d " " -f1 | sort | uniq >usuaris-$(date +%Y%m%d%H%M).txt
```

* *Un shutdown del vostre servidor al final de la classe. Volem que avisi als
  usuaris del sistema 5 minuts abans.*
```bash
$ at 9:55 Tue
at> wall "WARNING: shutdown at 9:00"
<...>

$ at 9:00 Tue
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
```bash
crontab
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
```bash
crontab -u root
21 16 * * sun /path/to/ocupacio.sh
``` 

*També volem controlar els usuaris innecessaris del sistema fent servir l'script
badusers.pl. Aquest control es realitzarà el primer dia de cada mes. Quina
entrada afegireu al crontab? De quin usuari? Que hem de fer perquè el llistat
d'usuaris que genera l'script ens arribi per correu?*

[Manual de mail](https://mailutils.org/manual/html_secition/mail.html). Per
poder rebre correu cal estar al grup `mail`.

