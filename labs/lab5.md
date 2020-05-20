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

