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
