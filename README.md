# ubuntu-remaster-autoinstall
This project is to remaster and autoinstall via network ubuntu server 22.04 (and maybe above)

## Usage </br>
## First step
Create a remastered iso image by using ./remaster.sh  
Place your modified files in their native path for an overlay mount into *./content/upper* like:  
`./upper/boot/grub/grub.cfg`  
Don't forget to modify your own target url for using remote configuration and static ip-setup in grub.cfg.  
You're able to modify the installer sqashfs, too.  
Therefore drop your custom stuff into *./sqashfs/upper*. Now: custom resolv.conf   
Call ./remaster.sh with an official iso-url as argument like:  
`./remaster.sh https://ftp.halifax.rwth-aachen.de/ubuntu-releases/jammy/ubuntu-22.04.1-live-server-amd64.iso`

Create a bootable medium out of your remastered image like any other iso bootimages.  

## Second step
cd into ./www and start a temorary http server: 
`python3 -m http.server 3003`

Rollout flavours see: [www/REDME.md](https://github.com/peedy2495/ubuntu-remaster-autoinstall/blob/master/www/README.md)

Now, boot from previously created media on your target hardware and enjoy the rollout ;-)

</br></br></br></br></br>

### References:
- https://ubuntu.com/server/docs/install/autoinstall-reference
- https://curtin.readthedocs.io/en/latest/index.html
- https://gist.github.com/s3rj1k/55b10cd20f31542046018fcce32f103e
- https://github.com/YasuhiroABE/ub2204-autoinstall-iso/blob/main/Makefile
- https://www.jimangel.io/posts/automate-ubuntu-22-04-lts-bare-metal