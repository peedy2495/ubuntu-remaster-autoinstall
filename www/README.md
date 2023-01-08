# Autoinstall and cloud-init Ubuntu 22.04 server

## Prerequisites:
- A x86 hardware platform with a smaller system an a bigger data SSD drive 
- create a ssh key pairs for admin and ansible via `ssh-keygen -t ed25519` and copy the public key contents in
  - user-data under autoinstall/ssh/authorized-keys for admin
  - user-data under autoinstall/user-data/users/name: ansible/ssh_authorized_keys for ansible
- create a password hash via 'mkpasswd' and paste it in user-data under autoinstall/identity/password here: "changeme"

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
| lv-root         | ext4       | /              | defaults                        | rest of space |
| lv-home         | ext4       | /home          | relatime,nodev,nosuid,noexec    | 10GB          |
| lv-vartmp       | ext4       | /var/tmp       | relatime,nodev,nosuid,noexec    | 10GB          |
| lv-varlog       | ext4       | /var/log       | relatime,nodev,nosuid,noexec    | 10GB          |
| lv-varlogaudit  | ext4       | /var/log/audit | relatime,nodev,nosuid,noexec    | 10GB          |
| data            | ext4       | /data          | relatime,nodev,nosuid,noexec    | full size     |
|                 | tmpfs      | /tmp           | relatime,nodev,nosuid,noexec    | 512M          |
|                 | tmpfs      | /var/crash     | relatime,nodev,nosuid,noexec    | 100M          |
|                 | tmpfs      | /dev/shm       | relatime,nodev,nosuid,noexec    | 512M          |
|                 | tmpfs      | /run           | relatime,nodev,nosuid,noexec    | 100M          |
|                 | tmpfs      | /proc          | relatime,nodev,nosuid,hidepid=2 |               |


### late procedures
- remove snapd
- upgrade system
- remove orphanned packages
- disable motd and plymouth
- modify fstab with all tmpfs volumes
- change timezone
- add admin to sudoers with full permissions
shutdown system to prevent infinite installations

### cloud-init part

- prevent root logins
- prevent ssh password logins
- create user ansible with full sudo permissions and ssh-key login
shutdown system after cloud-init provisioning