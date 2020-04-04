david.jurado.balaer - ASO - Grup 11

1. Per la comanda 'ps', determineu quines opcions a la línia de comandes s'han
de fer servir per poder veure una sortida "a mida" que contingui: username de
l'usuari que està executant el procés, PID, processador en el que ha corregut,
estat d'execució i arguments.

$ ps -e -o euser,pid,psr,s,args

Si en lloc del effective uid necessitessim saber el real uid, podem utilitzar
el camp ruser.

2. És possible amb aquesta sortida determinar quins són en cada moment els
processadors que estan executant un procés d'usuari?, i quin és aquest procés?

I tant que és possible! El camp s (estat d'execució) ens dirà que un procés
s'està execuntant quant estigui en estat R (RUNNING). La columna psr ens dirà
sobre quin processador. Sabrem quin procés és gràcies a la segona columna, que
és el pid.

3. A la comanda top, esbrineu quina opció interactiva permet visualitzar els
processadors, juntament amb els processos que cadascun està executant.

Per afegir una columna on poder veure el processador assignat a cada procés,
podem entrar en el menú de Fields Management prement f, i seleccionant el camp
P (LAST USED CPU). Si volem filtrar, podem prémer o i escriure P=<num_cpu>.

