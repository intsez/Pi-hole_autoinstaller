#!/bin/bash

## Pi-hole_autoinstaller
# Almost fully automatic Pi-hole installer. This script helps you to install Pi-hole with an admin web interface, several security options and add a huge number of frequently updated hosts/domains to the Pi-hole blacklist. All this with minimal user interaction.

## You will be able to:
#   - choose whether you want to install the default lighttpd web server or the Nginx web server(https://docs.pi-hole.net/guides/webserver/nginx/)
#   - install and enable cloudflared tunnel for DNS-Over-HTTPS DOH)(https://docs.pi-hole.net/guides/dns/cloudflared/)
#   - generate a Self-signed SSL certificate(https://en.wikipedia.org/wiki/Self-signed_certificate) with Diffie-Hellman file (https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange) and enable HTTPS connection(https://en.wikipedia.org/wiki/HTTPS)
#   - add an extra layer of security with basic HTTP authentication](https://en.wikipedia.org/wiki/Basic_access_authentication)
#   - automatically add a huge number of frequently updated hosts/domains to the Pi-hole blacklist (over 11 million):

# Colors:
#----------------
# standard prefix
CSI="\033["
# disable color
CEND="${CSI}0m"
# red background
CREDBG="${CSI}41m"
# red
CRED="${CSI}91m"
# green
CGREEN="${CSI}32m"

# run script as a root user
if [[ "$EUID" -ne 0 ]]; then
	echo
	echo -e "Sorry, you need to ${CREDBG}run this as root${CEND} !"
	echo
	exit 1
fi

# Clear screen
clear

# Main menu
echo "---------------------------------------------------------------------------"
echo -e " Donate Pi-hole at https://Pi-hole.net/donate/#donate ${CREDBG}(highly recommended)${CEND} "
echo "---------------------------------------------------------------------------"
echo
echo -e "${CGREEN}What would you like to do?${CEND}"
echo "   1) Install Pi-hole and add some basic security features."
echo "   2) Boost your Pi-Hole blacklist with a huge list of hosts and domains."
echo "   3) Exit"
echo

while [[ $WTD !=  "1" && $WTD != "2" && $WTD != "3" ]]; do
 	read -rp "Select an option [1-3]: "  -e WTD
done

case $WTD in
	1)
	# checking if Pi-hole is installed or if /etc/pihole directory exists if so, uninstall, delete it
		if [[ -d /etc/pihole ]]; then
			while [[ $UNPIHOLE !=  "y" && $UNPIHOLE != "n" ]]; do
			echo
				read -p "It looks like directory /etc/pihole exists. Delete it for you [y/n]?: " -e -i y UNPIHOLE
			done
			if [[ "$UNPIHOLE" = 'y' ]]; then
				pihole uninstall
				rm -rf /etc/pihole
				echo 
				echo -e "The directory ${CREDBG}/etc/pihole has been deleted${CEND}, Pi-hole is not installed. Please ${CREDBG}run the script again${CEND}."
				echo
				sleep 2;
				exit
			else
				echo
				echo -e "Sorry. You need to ${CREDBG}delete the /etc/pihole${CEND} directory before running this script. Bye ;)"
				echo
				exit
			fi
		fi
				
	# install nginx instead lighttpd
	echo
	echo "Would you like to:"
		while [[ $INNX != "y" && $INNX != "n" ]]; do
			read -rp "  [?] install and configure nginx web server instead of the default lighttpd web server? [y/n]?: " -e INNX
		done		
	# install cloudflared (DNS-Over-HTTPS) https://docs.Pi-hole.net/guides/dns/cloudflared/
		while [[ $DOH != "y" && $DOH != "n" ]]; do
			read -rp "  [?] install and enable Cloudflared, tunnel for DNS over HTTPS connection (DoH) [y/n]?: " -e DOH
		done		
		
		if [[ "$DOH" = 'y' ]]; then
		echo
			echo -e "${CGREEN}  Please select an architecture:${CEND}"
			echo "         1) AMD64 (most modern devices)"
			echo "         2) armhf (32-bit e.g. Raspberry Pi)"
			echo "         3) arm64 (64-bit e.g. Raspberry Pi)"
			echo          
			# display an architecture
			echo -e "         ----------------------------------${CRED}"
			echo -e "${CGREEN}          Your device architecture:${CEND} ${CREDBG}$(uname -m)${CEND}"
			echo -e "         ----------------------------------"
			echo 
			echo -e "      Binaries for other processor architectures can be found at:\n   ${CGREEN}   https://github.com/cloudflare/cloudflared/releases${CEND}"
			echo
			while [[ $ARCH !=  "1" && $ARCH != "2" && $ARCH != "3" ]]; do
				read -rp "      Your choice is [1-3]: " -e ARCH
			done
			echo
		fi
	# generate and configure self-Signed SSL
		while [[ $GSSL != "y" && $GSSL != "n" ]]; do
			read -rp "  [?] generate a self-signed SSL cert and enable HTTPS to the Pi-hole's web interface [y/n]?: " -e GSSL
		done
	# add basic http authentication with openssl
		while [[ $HTSA != "y" && $HTSA != "n" ]]; do
			read -rp "  [?] add an additional layer of security with Basic HTTP authentication (.htpasswd)? [y/n]?: " -e HTSA
		done
		echo
			
	# choose proper network interface
		echo -e "${CGREEN}Your network interfaces:${CEND} "
		echo -e "------------------------${CRED}"
			ls /sys/class/net/ 
		echo -e "${CEND}---------------------------------------------${CRED}"
			ip -4 -brief address show
		echo -e "${CEND}-------------------------------------------------------------------------"
		echo
			read -rp "Please type the network interface for Pi-hole and press enter (e.g. eth0): " -e NETINT 
		echo
	
	# ready to install		
		echo -e "Pi-hole is ready to be installed, ${CGREEN}press any key to continue${CEND} or ctrl +c to cancel..."
		read -n1 -r -p ""
				
	# update repositories, checking for required software if not, install it
		apt update;
		echo
		if [[ ! -e /usr/bin/curl ]] || [[ ! -e /usr/bin/sqlite3 ]] ; then
			apt install curl sqlite3 -y
		fi
				
	# chceck if pihole directory exists
		if [[ ! -d /etc/pihole ]]; then
			mkdir /etc/pihole
	# download SetupVars for automated instalaltion
		curl -o /etc/pihole/setupVars.conf -LO https://raw.githubusercontent.com/intsez/Pi-hole_autoinstaller/main/conf/setupVars.conf
		fi	
		
	# put selected network interface into Pi-hole configuration file
		sed -i "1s/.*/PIHOLE_INTERFACE=${NETINT}/" /etc/pihole/setupVars.conf
		if [[ ! -d ~/pihole ]]; then
			mkdir ~/pihole
		else
			curl -o ~/pihole/PiHoleBlackLists.txt -LO https://raw.githubusercontent.com/intsez/Pi-hole_autoinstaller/main/conf/lists/PiHoleBlackLists.txt
			curl -o ~/pihole/AddLists.sql -LO https://raw.githubusercontent.com/intsez/Pi-hole_autoinstaller/main/conf/lists/AddLists.sql
		fi
				
	# install Pi-hole, for more installation details go to: https://docs.Pi-hole.net/main/basic-install/
		curl -sSL https://install.Pi-hole.net | bash /dev/stdin --unattended
		
	# install nginx instead lighttpd
	# -------------------------------
		if [[ "$INNX" = 'y' ]]; then
			SOYC="nginx"
			if [[ -e /usr/sbin/nginx ]] || [[ -d /etc/nginx ]]; then
				echo 			
				echo "${CGREEN}It looks like the nginx web server is installed, skipping installation...${CEND} "
			else
			SOYC="lighttpt"			
				echo 	
				echo -e "${CGREEN}Please wait , uninstalling the lighttpd web server and installing nginx...${CEND}"
				echo 
				service lighttpd stop
				systemctl disable lighttpd
				apt --purge autoremove lighttpd*
				apt install nginx nginx-common -y
			fi
			
		# check php version and install proper modules for the Pi-hole
			PHP_VER=$(php -v | grep ^PHP | cut -b 5,6,7)
			apt install	php$PHP_VER-fpm php$PHP_VER-cgi php$PHP_VER-xml php$PHP_VER-sqlite3 php$PHP_VER-intl php-intl -y
			curl -o /etc/nginx/sites-available/pihole-nx.conf -LO https://raw.githubusercontent.com/intsez/Pi-hole_autoinstaller/main/conf/nginx/pihole-nx.conf
			sed -i 's/php7.4-fpm/'php$PHP_VER-fpm'/g' /etc/nginx/sites-available/pihole-nx.conf
			ln -s /etc/nginx/sites-available/pihole-nx.conf /etc/nginx/sites-enabled/
			echo
			echo -e "${CGREEN}Checking nignx configuration syntax and reloading web server...${CEND}"
			systemctl start php$PHP_VER-fpm
			systemctl enable php$PHP_VER-fpm
			rm -rf /etc/nginx/sites-enabled/default
			echo -e "${CGREEN}"
			nginx -t && nginx -s reload
			echo -e "${CEND}"					
			sleep 2;
		fi			
				
	# GENERATE SSL Diffie-Hellman (dhparam file). 
	# ------------------------------------------------
	# for stronger encryption is recommended to change values to 4096 bit. WARNING: Generating a 4096 dhparam file will consume a lot of time !
		if [[ "$GSSL" = 'y' ]]; then
			if [[ ! -e /usr/bin/openssl ]] ; then
				apt install openssl -y
			fi
			echo -e "${CGREEN}Please wait, generating Selfsigned SSL and Diffie-Hellman file...${CEND}" 
			echo			
			openssl req -new -x509 -nodes -days 720 -newkey rsa:2048 -keyout /etc/ssl/private/selfsigned.key -out /etc/ssl/certs/selfsigned.crt -subj "/C=XX/ST=XX/L=XX/O=XX/CN=pi.hole"
			openssl dhparam -out /etc/ssl/dhparam.pem 2048			
			chmod 600 /etc/ssl/dhparam.pem /etc/ssl/private/selfsigned.key /etc/ssl/certs/selfsigned.crt		
		# nginx SSL instructions			
			if [[ "$INNX" = 'y' ]]; then
				if [[ ! -d /etc/nginx/ssl ]] ; then
					mkdir -p /etc/nginx/ssl
				fi
				
				curl -o /etc/nginx/ssl/ssl-params.conf -LO https://raw.githubusercontent.com/intsez/Pi-hole_autoinstaller/main/conf/nginx/ssl-params.conf
				sed -i 's/#return/return/g' /etc/nginx/sites-available/pihole-nx.conf
				sed -i 's/#}/}/g' /etc/nginx/sites-available/pihole-nx.conf	
				sed -i 's/#server/server/g' /etc/nginx/sites-available/pihole-nx.conf
				sed -i 's/#listen/listen/g' /etc/nginx/sites-available/pihole-nx.conf	
				sed -i 's/#ssl_certificate/ssl_certificate/g' /etc/nginx/sites-available/pihole-nx.conf	
				sed -i 's/#include/include/g' /etc/nginx/sites-available/pihole-nx.conf
				echo -e "${CGREEN}"
				nginx -t && nginx -s reload
				echo -e "${CEND}"
			else
		# lighttpd SSL instructions
				cat /etc/ssl/private/selfsigned.key /etc/ssl/certs/selfsigned.crt > /etc/ssl/selfsigned.pem
				apt install	lighttpd-mod-openssl -y
				#rm -rf /etc/lighttpd/conf-available/*-ssl.conf
				curl -o /etc/lighttpd/conf-available/08-ssl.conf -LO https://raw.githubusercontent.com/intsez/Pi-hole_autoinstaller/main/conf/lighttpd/08-ssl.conf
				ln -s /etc/lighttpd/conf-available/08-ssl.conf /etc/lighttpd/conf-enabled/
		# restart lighttpd
				service lighttpd force-reload
			fi		
		fi
		
	# Generate password for Basic HTTP authentication with openssl
	# -------------------------------------------------------------
		if [[ "$HTSA" = 'y' ]]; then
			echo -e "${CRED}Now you need to set a password for Basic HTTP authentication.${CEND}"
			echo
			echo -e "${CGREEN}To add new users to the Basic HTTP passwords list in the future, type the following commands in terminal. Remember to change your username:${CEND}"
			echo
			echo "   1) sh -c \"echo -n 'ChangeUserName:' >> /etc/.htpasswd\""
			echo "   2) sh -c \"openssl passwd -apr1 >> /etc/.htpasswd\""
			echo 
			echo 
			echo -e "${CREDBG}Please type your username and press enter. This field cannot be empty!${CEND}"
			read  httpusr
			echo
			echo -e "Type ${CREDBG}password for ${httpusr}${CEND}and press enter"
			sh -c "echo -n '${httpusr}:' >> /etc/.htpasswd"
			sh -c "openssl passwd -apr1 >> /etc/.htpasswd"
			echo 
			echo -e "${CRED}The username and password have been saved in /etc/.htpasswd${CEND}"
			echo
			sleep 2;
						
			if [[ "$INNX" = 'y' ]]; then
				sed -i 's/#auth_basic/auth_basic/g' /etc/nginx/sites-available/pihole-nx.conf
				nginx -t && nginx -s reload
				echo
				sleep 2;
			else
				curl -o /etc/lighttpd/conf-available/07-auth.conf -LO https://raw.githubusercontent.com/intsez/Pi-hole_autoinstaller/main/conf/lighttpd/07-auth.conf
				ln -s /etc/lighttpd/conf-available/07-auth.conf /etc/lighttpd/conf-enabled/
				echo
				echo -e "${CGREEN}Checking lighttpd configuration syntax ..."
				echo
				lighttpd -t -f /etc/lighttpd/lighttpd.conf
				echo -e "${CEND}"
				sleep 2;
				systemctl restart lighttpd
				service lighttpd force-reload
			fi		
		fi
	
	# INSTALL CLOUDFLARED DoH (DNS over Https):
	# ------------------------------------------
		if [[ "$DOH" = 'y' ]]; then
			echo
			case $ARCH in
			1)
		# AMD64 (Debian and derivatives)
				cd ~/pihole
				curl -o ~/pihole/cloudflared-linux-amd64.deb -LO https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb 
				dpkg -i cloudflared-linux-amd64.deb
				
				if [ $? -eq 0 ]; then
					echo
					echo -e "${CGREEN}Cloudflare installed ${CEND}"
					echo
				else
					echo
					echo -e "${CREDBG}Something is wrong with dependencies. Attempt to fix.${CEND}"
					echo
					dpkg --configure -a; apt install -f -y; apt install --fix-broken -y 
					dpkg -i cloudflared-linux-amd64.deb
						if [ $? -eq 0 ]; then
							echo
							echo -e "${CREDBG}Sorry. You need to install cloudflared manually. ${CEND}"
							echo
							echo -e "${CGREEN} Press any key to continue Pi-hole installation ...${CEND}"
							read -n1 -r -p ""
						fi
				fi
			;;
			2)
		# armhf architecture (32-bit Raspberry Pi) 
				cd ~/pihole
				curl -o ~/pihole/cloudflared-linux-arm -LO https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm
				mv -f ./cloudflared-linux-arm /usr/local/bin/cloudflared
				chmod +x /usr/local/bin/cloudflared
			;;
			3)
		# arm64 architecture (64-bit Raspberry Pi)¶
				cd ~/pihole
				curl -o ~/pihole/cloudflared-linux-arm64 -LO https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64
				mv -f ./cloudflared-linux-arm64 /usr/local/bin/cloudflared
				chmod +x /usr/local/bin/cloudflared
			;;
		esac
		
	# CONFIGURING CLOUDFLARED TO RUN ON SYSTEM STARTUP
	# check if system uses systemd
	
				if [[ $(ps -p 1 -o comm=) == "init" ]] || [[ $(pidof systemd && echo "systemd" || echo "other") == "other" ]]; then
					echo
					echo -e "${CGREEN}It looks like your system doesn't use systemd. Once the installation is complete, you may need to start, enable cloudflared manually.${CEND}"
					echo
					# wait for user interaction		
					echo "Press any key to continue..."
					read -n1 -r -p ""
					echo 
				fi		
	
				useradd -s /usr/sbin/nologin -r -M cloudflared
				echo "CLOUDFLARED_OPTS=--port 5053 --upstream https://1.1.1.1/dns-query --upstream https://1.0.0.1/dns-query" > /etc/default/cloudflared
				chown cloudflared:cloudflared /etc/default/cloudflared
				chown cloudflared:cloudflared /usr/local/bin/cloudflared
				curl -o /etc/systemd/system/cloudflared.service -LO https://raw.githubusercontent.com/intsez/Pi-hole_autoinstaller/main/conf/cloudflared/cloudflared.service
				systemctl enable cloudflared
				systemctl start cloudflared
	
				# change DNS settings
				sed -i '/server=1.1.1.1/d' /etc/dnsmasq.d/01-pihole.conf
				sed -i '/server=1.0.0.1/d' /etc/dnsmasq.d/01-pihole.conf
				echo "server=127.0.0.1#5053" >> /etc/dnsmasq.d/01-pihole.conf
				sed -i '/PIHOLE_DNS_1=1.1.1.1/d' /etc/pihole/setupVars.conf   
				sed -i '/PIHOLE_DNS_2=1.0.0.1/d' /etc/pihole/setupVars.conf   
				echo "PIHOLE_DNS_1=127.0.0.1#5053" >> /etc/pihole/setupVars.conf
			#restart DNS server
				pihole restartdns
				service pihole-FTL restart
			# where to check DOH
				echo
				echo -e "${CREDBG}To check if the cloudflared works go to https://1.1.1.1/help ${CEND}"
				echo
				sleep 2;
		fi

	# CREATE FIRST GRAVITY DATABASE AND UPDATE
	# ----------------------------------------
		pihole -g
		echo
	# make backup of gravity database, add more lists and update again
		echo
		echo -e "${CGREEN}Please wait, backing up the gravity database ...${CEND}"
		cp /etc/pihole/gravity.db /etc/pihole/gravity.db"-$(date +%d-%m-%y#%H-%M-%S).old"
		echo 
		echo -e "A copy of the Gravity database has been saved in: ${CREDBG}/etc/pihole/gravity-$(date +%d-%m-%y#%H-%M).bck${CEND}"
		echo -e "${CGREEN}To free up some space, delete the aforementioned database! ${CEND}"
	# add new lists:
		sqlite3 /etc/pihole/gravity.db < /root/pihole/AddLists.sql
		echo
		sleep 2;
	# start Pi-hole
		service pihole-FTL start		
		systemctl enable pihole-FTL
		systemctl start pihole-FTL
	# set the passwrord for web interface
		echo -e "${CREDBG}Please set a password for the web interface:${CEND}"
		echo
			pihole -a -p
		echo 
	# check Pi-hole version and update previously added lists
		echo -e "${CGREEN}Please wait, adding hosts/domains to the blacklist...${CEND}"
		echo
		pihole updatechecker && pihole updatechecker remote	
		pihole -g
		echo
		# restart cloudflare
		systemctl restart cloudflared
		
		# reload cloudflare cloudflared
		#systemctl reload cloudflared
		echo -e "Try to open the web interface by typing one of the following addresses in your web browser:\n${CRED}IP_of_your_device/admin ${CEND}or ${CRED}localhost/admin${CEND} or ${CRED}pi.hole/admin${CEND}"
		echo
		echo -e "The configuration files can be found in the following locations:\n 1) ${CRED}~/pihole${CEND}\n 2) ${CRED}/etc/pihole${CEND}\n 3)${CRED} /etc/$SOYC ${CRED}\n\n${CGREEN}   That's it. Bye bye${CEND};)"
		echo
	;;
	2)
	# add lists and update gravity database
		echo
		if [[ ! -d /etc/.pihole ]] || [[ ! -d /opt/pihole ]] ; then
			echo
			echo -e "${CREDBG}It seems like Pi-hole is not installed. Please install it before proceeding.${CEND}\n\n ${CGREEN} Bye !${CEND}"
			echo
			exit
		fi	
	# check if the necessary software is installed, if not, install it
		if [[ ! -e /usr/bin/curl ]] || [[ ! -e /usr/bin/sqlite3 ]] ; then
			apt install curl sqlite3 -y
		fi
				
		if [[ ! -d ~/pihole ]]; then
			mkdir ~/pihole
		else
			curl -o ~/pihole/PiHoleBlackLists.txt -LO https://raw.githubusercontent.com/intsez/Pi-hole_autoinstaller/main/conf/lists/PiHoleBlackLists.txt
			curl -o ~/pihole/AddLists.sql -LO https://raw.githubusercontent.com/intsez/Pi-hole_autoinstaller/main/conf/lists/AddLists.sql
		fi
	
	# make backup of gravity database, add more lists and update again
		echo
		echo -e "${CGREEN}Please wait, backing up the Gravity database ...${CEND}"
		cp /etc/pihole/gravity.db /etc/pihole/gravity.db"-$(date +%d-%m-%y#%H-%M-%S).old"
		echo 
		echo -e "A copy of the Gravity database has been saved in: ${CREDBG}/etc/pihole/gravity-$(date +%d-%m-%y#%H-%M).bck${CEND}"
		echo -e "${CGREEN}To free up some space, delete the aforementioned database! ${CEND}"
	# add new lists:
		sqlite3 /etc/pihole/gravity.db < /root/pihole/AddLists.sql
		echo
	# wait for user interaction		
		echo "Press any key to continue..."
		read -n1 -r -p ""
			pihole -g
		echo
		echo -e "The files used for an update can be found in the ${CRED}~/pihole${CEND} directory.\n\n${CGREEN}   That's it. Bye bye ${CEND};)"
		echo
	;;
	3)
	# Exit
		echo
		echo -e "${CGREEN}  OK. Bye bye ${CEND}"
		echo
		exit
	;;
	esac
	
