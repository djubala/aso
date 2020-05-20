# Pràctica 5: còpies de seguretat
## Partició per emmagatzemar les còpies de seguretat

Commandes utlitzades per preparar la partició:

```bash
fdisk /dev/sda
# inside fdisk: n, first sector: default, last sector: +100M, w
mkfs.ext3 /dev/sda8
mkdir -m 700 /backup
mount /dev/sda8 /backup
```

Sembla que després del mount cal fer chmod una altra vegada. Amb el mkdir només
posem el mode del mountpoint.

Si muntem amb `mount -o remount,ro`, el mode del directori segueix igual, pero
el read-only (`ro`) fa que no puguem escriure.

Per fer el canvi permanent, modificarem l'fstab. Afegim una entrada:
```fstab
/dev/sda8       /backup         ext3    ro,defaults     0       2
```
`mount -a` remunta les entrades del fstab. Ara ens hem quedat en read-only, ni
root pot escriure. Podem fer `mount -o remount,rw`.

## Realització de còpies amb tar
### Realització de còpies completes

Aconseguim aquest format de data amb `date +%Y%m%d%H%M`.

Podem fer una còpia completa del `/etc` amb
`tar -cf backup-etc-nivell0-$(date +%Y%m%d%H%M).tar /etc`. No entenc per què
no es recomana, en teoria el plaintext dóna bon ratio de compresió. També
imagino que pot afectar al temps de cmprimir i descomprimir. Per comprimir,
podem afegir els flags `-z` (gz), `-j` (bz2) o `-J` (xz).

Per ignorar fitxers amb tar, podem fer servir:
* `--exclude-vcs-ignores` suporta .gitignore i similars.
* `-X <exclude_file>`: el que utilitzarem. Pattern matching definit al
  `man 7 glob`. Una línia per cada pattern. Semblants als del shell.

Per crear una llista de signatures i verificar, utilitzarem:
```bash
md5sum FILES >> LIST.asc
md5sum -c LIST.asc
```
## Realització de còpies incrementals

`tree -D` és bastant útil per veure les dates de tot el directori. Exemple:
```
root@aso-client:/# tree -D /root
/root
├── [May 20 12:22]  cereales
│   ├── [May 20 12:22]  chocapic
│   └── [May 20 12:22]  kellogs
├── [May 20 12:22]  flan
└── [May 20 12:20]  verduras
    ├── [May 20 12:20]  buenas
    │   ├── [May 20 12:20]  acelgas
    │   ├── [May 20 12:20]  brocoli
    │   ├── [May 20 12:20]  espinacas
    │   └── [May 20 12:20]  judias
    └── [May 20 12:20]  malas
        ├── [May 20 12:20]  alcachofas
        ├── [May 20 12:20]  cebolla
        └── [May 20 12:20]  coliflor
```

1. Fem la còpia de nivell 0. Ens guardarem els md5s de tots els backups al
   mateix fitxer:
```bash
tar -cf backup-root-nivell0-$(date +%Y%m%d%H%M).tar /root
md5sum BACKUP.tar >list.asc
```

2. Tocarem els kellogs per forçar algun canvi:
```bash
touch /root/cereales/kellogs
```

3. Per fer la còpia incremental, farem `--newer=` respecte al fitxer backup de
   nivell 0. Ojo perquè el fitxer que indiquem ha de començar amb `.` o `/`, si
   no l'interpretarà com una data. Sembla que copia tots els directoris, encara
   que no estiguin modificats. Fitxers de dades, només els modificats.
```bash
tar -cf backup-root-nivell1-$(date +%Y%m%d%H%M).tar --newer=./BACKUP0.tar /root
md5sum BACKUP-1-1.tar >>list.asc
```

4. No se m'acudeix cap problema potencial especialment greu amb lo del
   ` --newer`. Potser li queda la data de quan s'acaba d'escriure el backup. SI
   algú toca algun fitxer mentre s'està fent el backup, no ho acumularem en el
   següent incremental? O potser si el backup es una còpia no té la data ben
   posada?

5. Crearem la xocolata i esborrarem les verdures dolentes. També actualitzarem
   el brocoli.
```bash
mkdir /root/chocolate
touch /root/chocolate/blanco
touch /root/chocolate/negro
touch /root/verduras/buenas/brocoli
rm -r /root/verduras/malas
```
```
root@aso-client:/# tree -D /root
/root
├── [May 20 12:22]  cereales
│   ├── [May 20 12:22]  chocapic
│   └── [May 20 12:35]  kellogs
├── [May 20 12:55]  chocolate
│   ├── [May 20 12:55]  blanco
│   └── [May 20 12:55]  negro
├── [May 20 12:22]  flan
└── [May 20 12:55]  verduras
    └── [May 20 12:20]  buenas
        ├── [May 20 12:20]  acelgas
        ├── [May 20 12:55]  brocoli
        ├── [May 20 12:20]  espinacas
        └── [May 20 12:20]  judias
```

6. Fem la segona còpia incremental. Utilitzarem el flag `--verify` per
   verificar. Hi ha algun warning que no m'agrada, potser té que veure amb
   posar `/root` amb `/`.
```bash
tar -cf backup-root-nivell1-$(date +%Y%m%d%H%M).tar --verify --newer=./BACKUP-1-1.tar /root
md5sum BACKUP-1-2.tar >>list.asc
```

7. Per verificar els checksums:
```bash
md5sum -c list.asc
```

### Restauració de còpies de seguretat

Hem restaurat primer el nivell 0, després els incrementals de vell a nou. Hem
fet servir la commanda `tar -xf BACKUP.tar`.

Hi ha un problema amb els fitxer esborrats. És impossible diferenciar entre
fitxers esborrats i fitxers no modificats en els backups incrementals. Al
restaurar, les verdures dolentes segueixen allà. Tot i axí, seran esborrats
quan fem un altre nivell 0.

També hi ha un problema perquè estic fent backup incremental respecte a l'últim
backup incremental. Potser s'haurien de fer sempre respecte al nivell 0... Així
no caldria fer la cadena de restauració, seria suficient amb restaurar el
nivell 0 i l'últim incremental.

### Restauració d'un fragment

Per restaurar un fragment, cal indicar el seu path de dins del tar. Aquests
paths comencen per `/`. També podem fer servir wildcards amb `--wildcard`.
Imagino que seran tipus glob.
```bash
tar -xf BACKUP.tar /PATH/INSIDE/TAR
```

## Realització de còpies usant RSYNC
### Realització de backups a través d'una xarxa

Necessitem instalar el servidor ssh i l'rsync. Sembla que s'activen sols.
```bash
apt install openssh-server rsync
systemctl status ssh rsync
```

Per defecte, a Debian/Ubuntu el servidor ssh no permet login a root via
password. Cal anar a `/etc/ssh/sshd_config`, descomentar
`PermitRootLogin` i posar-lo a `yes`. Després reiniciem el servidor amb
`systemctl restart ssh`.

### Realització de còpies completes

Tirem la comanda que ens diuen:
```bash
`rsync -avz /root -e ssh root@localhost:/backup/backup-rsync/`:
```
* `-a`: recursion, keep almost everything . Si volem mantenir hardlinks, `-H`
* `-v`: verbose, de tota la vida
* `-z`: compress *during transfer*
* `-e`: especifica la commanda de remote shellA

Després de borrar el `arxiu_nou.txt` en l'origen i sincronitzar, segueix al
directori backup. Podriem fer que s'esborrés amb el flag `--delete`.

El rsync incorpora els mateixos excludes basats en glob que el tar. Podriem
fer `--exclude='*.txt'` o un exclude-file amb `--exclude-from`.

La diferencia entre `source` i `source/`:
* `source`: copia el directori
* `source/`: copia els continguts del directori

### Realització de còpies incrementals inverses

Veure `invers.bash`. Al modificar un fitxer, la versió antiga passa a
l'incremental ,en canvi, en el directori complet queda la versió més nova.
Al esborrar un fixer, desapareix del complet i l'última versió queda a
l'incremental més recent.

Per aclarar, el incremental sempre es fa respecte la còpia complerta, no altres
incrementals. Per restaurar, caldria restaurar primer el complet i
només un dels incrementals.

### Realització de còpies incrementals inverses tipus snapshot (3)
#### Repàs d'enllaços durs

* Comprovem que dos fitxers pertanyen al mateix inode amb stat. Exemple:
```bash
stat doppelganger.pdf monitoritzacio.pdf
  File: doppelganger.pdf
  Size: 28082     	Blocks: 56         IO Block: 1024   regular file
Device: 805h/2053d	Inode: 65819       Links: 2
Access: (0644/-rw-r--r--)  Uid: ( 1000/     aso)   Gid: ( 1000/     aso)
Access: 2020-05-20 14:02:06.000000000 +0200
Modify: 2020-04-04 14:15:24.000000000 +0200
Change: 2020-05-20 18:37:56.000000000 +0200
 Birth: -
  File: monitoritzacio.pdf
  Size: 28082     	Blocks: 56         IO Block: 1024   regular file
Device: 805h/2053d	Inode: 65819       Links: 2
Access: (0644/-rw-r--r--)  Uid: ( 1000/     aso)   Gid: ( 1000/     aso)
Access: 2020-05-20 14:02:06.000000000 +0200
Modify: 2020-04-04 14:15:24.000000000 +0200
Change: 2020-05-20 18:37:56.000000000 +0200
 Birth: -
```

* Els dos fitxers tenen els mateix inode, per tant, apunten als mateixos blocs
  de dades. Si modifiquem un també veurem els canvis en l'altre.

* Els dos fitxers tenen el mateix inode, que conté el mode d'accés. Si fem
  `chmod`, veurem els canvis en els dos.

* El `cp` ens tira un error dient que són el mateix fitxer. Amb el flag
  `--remove-destination`, la copia funciona, pero el destí ja no és un hard
  link. Imagino que equival a fer un rm i despres copiar. Curiosament, un
  `cat FILE1 > FILE2` es trunca a si mateix. En canvi, un append amb
  `cat FILE1 >> FILE2` dóna error perque són el mateix fitxer.

* Si esborrem un dels dos, només es decrementa el número de refències de
  l'inode. Podem seguir accedint.

#### Backups tipus snapsot amb rsync i cp -al

### Script per fer backups tipus snapsot

Una dada interessant és que aquest script tracta un canvi en els modes d'u
fitxer com una modificació. Per tant, els tornarem a copiar.

L'script té bona pinta. La primera vegada que l'executes es fa un backup
complet. Respecte a la mida dels fitxers, he fet una prova al fer diversos
backups sense modificar res. Si fem `du -h` de cada `daily.`, totes ocupen
el mateix. Pero si pujo un nivell i faig `du -h` del directori que conté els
`daily`, la mida es propera a la d'un sol `daily.`. Això és perquè el `du` és
intel·ligent i no suma el pes d'un hard link dues vegades. La mida extra
probablement vingui de replicar els fitxers de tipus directori en si, ja que no
es poden fer hard links a directoris.

* La restauració és extremadament simple. Podriem fer un `rsync` a la inversa
  per tal de només substituir els fitxers més recents i tornar al passat. Ojo,
  no volem eliminar els excludes, així que no posarem el flag
  `--delete-excluded`.
```bash
rsync -va --delete --exclude-from EXCLUDE_FILE /backup/snapshots/daily.N/ /root
```

* No veig la manera d'arreglar-lo amb `cp`, perquè cal respectar els excludes
  que no són al directori font i potser cal eliminar algun fitxer.



