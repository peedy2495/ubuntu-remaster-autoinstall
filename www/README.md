# Autoinstall and cloud-init Ubuntu 22.04 server

## Prerequisites:
- A x86 hardware platform with a smaller system an a bigger data SSD drive 
- create a ssh key pairs for admin and ansible via `ssh-keygen -t ed25519` and copy the public key contents in
  - user-data under autoinstall/ssh/authorized-keys for admin
  - user-data under autoinstall/user-data/users/name: ansible/ssh_authorized_keys for ansible
- create a password hash via 'mkpasswd' and paste it in user-data under autoinstall/identity/password; now: "changeme"

## Explanation of this user-data config

### Network
Search all interfaces beginning with "enp" and add them to an 802.2ad bond

### Storage
Take the smallest SSD and create system-partitions

Take a SSD with serial starting like "CT"  
Create an ext4 partition mounted on /data  

Use several tmpfs mounts to keep volatile stuff away from physical storage (-> late procedures)  

**Summary:**

| volume          | filesystem | mountpoint     | mountoptions                    |size           |
|-----------------|------------|----------------|---------------------------------|---------------|
| efi             | fat32      | /boot/efi      | defaults                        | 1GB           |
| boot            | ext4       | /boot          | defaults                        | 2GB           |
| lv-root         | ext4       | /              | defaults                        | 20GB          |
| lv-home         | ext4       | /home          | relatime,nodev,nosuid,noexec    | 10GB          |
| lv-opt          | ext4       | /opt           | relatime,nodev,nosuid,noexec    | 1GB           |
| lv-mnt          | ext4       | /mnt           | relatime,nodev,nosuid,noexec    | 4KB           |
| lv-varlib       | ext4       | /var/lib       | relatime,nodev,nosuid,noexec    | rest of space |
| lv-vartmp       | ext4       | /var/tmp       | relatime,nodev,nosuid,noexec    | 10GB          |
| lv-varlog       | ext4       | /var/log       | relatime,nodev,nosuid,noexec    | 10GB          |
| lv-varlogaudit  | ext4       | /var/log/audit | relatime,nodev,nosuid,noexec    | 10GB          |
| data            | ext4       | /data          | relatime,nodev,nosuid,noexec    | full size     |
|                 | tmpfs      | /tmp           | relatime,nodev,nosuid,noexec    | 512MB         |
|                 | tmpfs      | /var/crash     | relatime,nodev,nosuid,noexec    | 100MB         |
|                 | tmpfs      | /dev/shm       | relatime,nodev,nosuid,noexec    | 512MB         |
|                 | tmpfs      | /run           | relatime,nodev,nosuid,noexec    | 100MB         |
|                 | tmpfs      | /proc          | relatime,nodev,nosuid,hidepid=2 |               |
|                 | tmpfs      | /media         | relatime,nodev,nosuid,noexec    | 4KB           |



### late procedures
- remove snapd
- remove modemmanager (disable inet over cellular networks)
- upgrade system
- remove orphanned packages
- disable motd and plymouth
- modify fstab with all tmpfs volumes
- change timezone
shutdown system to prevent infinite installations

### cloud-init part

- prevent root logins
- prevent ssh password logins
- create user ansible with full sudo permissions and ssh-key login
shutdown system after cloud-init provisioning

### Network troubleshooting
Dependent to your L2/L3 switch and it's configuration, maybe it's necessary to connect only one line during first installation step. After the first step, connect all bonded lines for powering up the second cloud-init part. 