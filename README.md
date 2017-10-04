# SSH - automated CA ssh key distribution for server/client
This script is used for semi-automated client/server SSH authentication using local certification authority.

Requirements:
	Local CA installed and sigend certificates:
#cd ~
#ssh-keygen -f server_ca
#ssh-keygen -s server_ca -I host_auth_server -h -n auth.example.com -V +52w /etc/ssh/ssh_host_rsa_key.pub
#ssh-keygen -f users_ca

	Local ssh-key pair
#ssh-keygen
#cat .ssh/id_rsa.pub > src/authorized_keys_local
 
Usage:
#sh cert_authentication.sh
You will be prompted for remote server name, root password, new user name.

Script will 
1. login to server using hostname and password provided 
2. add server running script to ssh authorized servers for passwordless logins.
3. download ssh host key from server and sign it using local certification authority
4. upload files back to server
5. create username on the server as provided
6. update ssh daemon configuration and restart ssh service
7. ask for client public ssh key and sign it using local CA
8. output instruction where to put those files

Please note, that you have to edit this script as follows:  
"@cert-authority $name YOUR- cat ~/server_ca.pub -HERE"
 