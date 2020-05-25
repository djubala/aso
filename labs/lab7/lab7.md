# Lab 7: Virtualisation

## 7.3 Installation

`fallocate -l 8192M /vms/vm_1.img` *What is the `fallocate` command doing?*

Crea un fitxer amb blocs contigus de mida 8192M buit. Utilitza una crida al
sistema només copmatible amb ext4. La diferència amb l'altra commanda
`dd if=/dev/zero of=/vms/vm 1.img bs=1024 count=10000000` és que aquesta última
haurà de fer operacions d'IO per copiar tots els zeros al disc, així que serà
més lenta.

*Because of a security restrictions in the network configuration we are going
to use, the account we are going to use to manipulate the VMs needs to have
superuser privileges. How do we enable these privileges?*

Podem afegir-lo al grup de `sudo`.

... (pregunes del installer)

*First we need to create an empty virtual floppy disk named floppy.img, with
1.44MB size, and format it with fat file system. Which commands are you going
to use?*

```bash
fallocate -l 1.44M /vms/floppy.img
mkfs.vfat /vms/floppy.img
```

*Now we have to mount the virtual image in order to copy our configuration
file on it. `mount -t vfat floppy.img /mnt/ -o loop`. What is the purpose of
`-o` loop in the mount command?*

Especifica que cal utilitzar una interfície de loop. És necessari quan volem
muntar un filesystem que es troba a dins d'un fitxer de dades.

## 7.4 Network configuration

*In order to create a permanent bridge in our system we have to edit the file
which contains the configuration of our network interfaces. Which one is it?*

És el `/etc/network/interfaces`.

## 7.5 Virtual machine control

*How do we shutdown a vm? Reboot?*

```bash
virsh shutdown vm_1
virsh reboot vm_1
```

(TO BE CONTINUED...)
