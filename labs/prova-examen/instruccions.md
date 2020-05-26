# Installation of the OS (VM prova examen)

## 1.3 Installation
### 1.3.1 Hardware Identification

Ni `lspci` ni `lsblk` funcionen. Per detectar la xarxa, hem fet `ip link show`,
que ens mostra que la interfície es diu `enp0s3`. Si busquem en el `dmesg`,
veurem quin hardware hi ha al darrere. Amb el disc, farem `lsblk` i despré
buscarem `sda` al `dmesg`.

| **Part**              | **Hardware found** | **Device name**
| *Network Card*        | Intel PRO/1000     | enp0s3
| *Internal Hard Drive* | SCSI disk          | sda

### 1.3.2 Disk configuration: partitions

No cal fer particions, ja tenim una feta per a `/` que ocupa tot el disc. El
mateix amb els següents apartats.

## 1.5 Post-configuration
### 1.5.1 Configuring filesystems

Podem canviar la freqüència dels checks amb `tune2fs -i 28 /dev/sda1`.

### 1.5.2 Configuring system login messages

Abans del login, `/etc/issue`. Després del login correcte, `/etc/motd`.

Per buscar el fitxer segons el contingut, podem fer `grep -r PATTERN /etc`, que
busca en tot l'`/etc` un fitxer que contingui aquest patró.

### 1.5.3 Network configuration
#### Permanent configuration

El servei de systemd encarregat de la xarxa és el `networking.service`, que
s'encarrega d'aixecar les interfaces en el boot amb `ifup` i `ifdown`. Aquestes
dues commandes llegeixen del `etc/network/interfaces`. Sembla que nop existeix,
per tant, l'haurem de crear.

```
auto enp0s3

iface enp0s3 inet auto
```
