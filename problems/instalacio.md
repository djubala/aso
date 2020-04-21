# Instal·lació d'aplicacions
###### david.jurado.balaer - ASO - Grup 11

* Quines maneres d'instal.lar aplicacions coneixeu?
* Buscar informació sobre els següents formats de distribució d'applicacions: tar, gz, rpm, deb i zip.
* Indiqueu les comandes [i les seves opcions] que es poden fer servir per:
  * Veure el contingut d'aquests tipus de fitxers
  * Extreure el seu contingut, amb possibilitats d'extreure'l només parcialment
  
## tar

El tar (**T**ape **AR**chive) és un format que ens permet empaquetar diversos fitxers i directoris dins d'un únic fitxer .tar. No incorpora cap tipus de compressió.

* Per veure els seus continguts, podem fer servir GNU tar així:

```
$ tar -tf aso.tar
aso/
aso/scripts/
aso/scripts/BadUser.sh
aso/scripts/BadUsers.sh
```
* També podem passar com argument despres del `-t` els fitxers i directoris dins del .tar que volem que llisti. Fins i tot podem especificar wildcards.

```
$ tar -t aso/scripts/ -f aso.tar
aso/scripts/
aso/scripts/BadUser.sh
aso/scripts/BadUsers.sh
```
```
$ tar --wildcards -t 'aso/scripts/BadUser*' -f aso.tar
aso/scripts/BadUser.sh
aso/scripts/BadUsers.sh
```

* Per extreure el contingut, podem fer:

```
$ tar -xf aso.tar
```

* També podem passar com argument després del `-x` els fitxers dins del .tar que volem extreure. Crearà una jerarquia de directoris que només conté els fitxers que hem especificat. També admet els wildcards de la mateixa manera que a l'exemple anterior.

```
$ tar -x aso/scripts/BadUser.sh -f aso.tar
```

## gz

El format .gz (**GNU Z**ip) és un format únicament de compressió. Això vol dir que no és capaç de combinar múltiples fitxers en un de sol, com el tar, sinó que només pot comprimir fitxers de dades individuals. Per aquest motiu, moltes vegades es complementa amb el .tar per tal de comprimir directoris. D'aquets manera podrem comprimir un .tar i convertit-lo en un .tar.gz.

* Utilitzant l'opció `-l` podem saber el nom i la mida del fitxer abans i després de ser comprimit:

```
$ gzip -l BadUser.sh.gz
         compressed        uncompressed  ratio uncompressed_name
                650                1194  48.0% BadUser.sh
```

* Combinat amb el tar, també podem fer les mateixes operacions per llistar, extreure i extreure parcialment si afegim el flag `-z`:

```
$ tar -ztf <.tar.gz>
```

```
$ tar -zxf <.tar.gz>
```

```
$ tar -zx <fitxer_interior> -f <.tar.gz>
```

## rpm

El format rpm (**R**PM **P**ackage **M**anager) es el que s'utilitza en distribucions de Linux com ara RHEL, Fedora, OpenSUSE... Un fitxer .rpm té una part de metadades i després un payload arxivat amb `cpio`(eina similar a `tar`) i comprimit amb `gzip`. Si no estem en una distribució que utilitzi el gestor de paquets rpm, podem utlitzar la comanda `rpm2cpio`per extreure el fitxer .cpio, que el manipularem després amb les seves pròpies eines.

* Podem fer les mateixes operacions de llistar, extreure i extreure parcialment. Quan utilitzem `-q`, es refereix a *query*:

```
$ rpm -ql <.rpm>
# o també
$ rpm2pio <.rpm> | cpio -it
```

```,
$ rpm2cpio  <.rpm> | cpio -id
```

```
$ rpm2cpio <.rpm> | cpio -i <fitxer_interior>
```

## deb

El deb és el format de distribució de paquets de les distros absades en Debian, com ara Ubuntu, Trisquel... Al seu interior conté dos fitxers, `control.tar`i `data.tar`, que conetenen les metadades i el software del paquet respectivament. No tenen per que ser un simple .tar, també poden ser .tar.gz, .tar.bz2, etc. Podem utilitzar el `dpkg` o eines d'arxiu per treballar amb els .deb.

* Llistar contingut. Amb el `dpkg` només podem vere el contingut del `data.tar`. En aquest cas concret, els continguts del .deb venien en format .xz (per això el `-J`).

```
# només veiem el data.tar
$ dpkg-deb -c <.deb>
```

```
$ ar t <.deb>
debian-binary
control.tar.xz
data.tar.xz
$ ar x <.deb> data.tar
$ tar -Jtf data.tar
```

* Extreure:

```
# extreu només el data.tar
$ dpkg-deb -x <.tar>
# extreu el data.tar i el contingut del control.tar al subdirecotri DEBIAN
$dpkg-deb -R <.tar>
```

```
$ ar x <.deb> data.tar
$ tar -xf data.tar
```

* Extreure una selecció:

```
$ tar -x <fitxer_interior> -f <.tar>
```

## zip

El format zip és un format que permet empaquetar *i* comprimir fitxers. Va ser implementat per primera vegada en el software PKZIP per al MS-DOS.

* Llistar els continguts:

```
$ unzip -l <.zip>
```

* Extreure:

```
$ unzip <.zip>
```

* Extreure una selecció:

```
$ unzip <.zip> <fitxer_interior>
```
