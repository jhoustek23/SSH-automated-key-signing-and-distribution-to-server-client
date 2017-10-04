scripts/cert_authentication.sh
#!/bin/bash
read -p "Servername : " name
read -p "Root password : " password
read -p "Username : " user

        #Give ourselves passwordless authentication
sshpass -p "$password" ssh -o StrictHostKeyChecking=no root@$name "echo '$(cat /root/scripts/src/authorized_keys_local)' >> /root/.ssh/authorized_keys && sort -u /root/.ssh/authorized_keys -o /root/.ssh/authorized_keys"

        #Get server SSH public key
scp root@$name:/etc/ssh/ssh_host_rsa_key.pub .

        #Sign it with our CA
ssh-keygen -s server_ca -I host_$name -h -n $name -V +520w ssh_host_rsa_key.pub

        #Upload signed key back to server
scp ssh_host_rsa_key-cert.pub root@$name:/etc/ssh/

        #Upload Users CA public key
scp users_ca.pub root@$name:/etc/ssh/

        #Cleaning
rm ssh_host_rsa_key.pub ssh_host_rsa_key-cert.pub -f

        #Create user and enable CA certs on server
ssh -o StrictHostKeyChecking=no root@$name "useradd $user"
ssh -o StrictHostKeyChecking=no root@$name "echo HostCertificate /etc/ssh/ssh_host_rsa_key-cert.pub >> /etc/ssh/sshd_config && sort -u /etc/ssh/sshd_config -o /etc/ssh/sshd_config"
ssh -o StrictHostKeyChecking=no root@$name "echo TrustedUserCAKeys /etc/ssh/users_ca.pub >> /etc/ssh/sshd_config && sort -u /etc/ssh/sshd_config -o /etc/ssh/sshd_config"
ssh -o StrictHostKeyChecking=no root@$name "/etc/init.d/sshd restart"

        #Client cert sign
rm id_rsa.pub id_rsa-cert.pub -f
echo    "#################################################################################"
echo            "Paste client public key (/home/$user/.ssh/id_rsa.pub):"
echo    "#################################################################################"
read -p "Client cert (id_rsa.pub) : " client
echo $client > id_rsa.pub
ssh-keygen -s users_ca -I user_$user -n $user -V +520w id_rsa.pub
echo
echo
echo
echo    "#################################################################################"
echo            "Signed client cert (place it to /home/$user/.ssh/id_rsa-cert.pub):"
echo    "#################################################################################"
echo
echo
cat             id_rsa-cert.pub
echo
echo
echo    "#################################################################################"
echo           "Add this to client (/home/$user/.ssh/known_hosts):"
echo    "#################################################################################"
echo
echo            "@cert-authority $name ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDdB9P8rN+14+AG7VD6QnwJNNL9ZDQHpbd5/pLkG92JB0JC+vyiPeoXfm+NQUTXK5VIKKePVKDFY2tjP4e2u5uXvhfO7pjrciUVZgnyNZUA6Mx6+H9tSIT7FNQuMKe794BgYnjk0XPfM0+/XoWIAQ17ZRgrWlCEMN
H+/8Xjys3Sit7yQ/bg71DO1xv53hLR2F5a2OpbdrbJ1VjK4oHqb0+aVoZglCZ8lju6EMedeUflnb0mY2QUf6duAM4/bCyA0BCyy9B4l91l0rwkJvRNWLSZloTGUWlUz3F3sPOzHu1k64qSyqEawxXhoxJgvwPdgq0YV3C8lo9P4VXn31xptxF3 root@auth"
echo
echo    "#################################################################################"
