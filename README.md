## Pi-hole_autoinstaller
This script helps you to install [Pi-hole](https://github.com/pi-hole/pi-hole) with an admin web interface, several security options and adds a huge number of frequently updated hosts/domains to the Pi-hole blacklist. All this with minimal user interaction.

## You will be able to:
* choose whether you want to install the default lighttpd web server or the [Nginx web server](https://docs.pi-hole.net/guides/webserver/nginx/)
* install and enable [cloudflared](https://docs.pi-hole.net/guides/dns/cloudflared/) tunnel for DNS-Over-HTTPS (DoH)
* generate a [Self-signed SSL certificate](https://en.wikipedia.org/wiki/Self-signed_certificate) with [Diffie-Hellman](https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange) file and [enable HTTPS connection](https://en.wikipedia.org/wiki/HTTPS)
* add an extra layer of security with [basic HTTP authentication](https://en.wikipedia.org/wiki/Basic_access_authentication)
* automatically add a huge number of frequently updated hosts/domains to the Pi-hole blacklist ([over 11 million](https://raw.githubusercontent.com/intsez/Pi-hole_autoinstaller/main/conf/lists/PiHoleBlackLists.txt)):

![obraz](https://github.com/intsez/Pi-hole_autoinstaller/assets/25661004/2c3d4646-bbe2-48fe-b5c4-1dd05380b590)

## The script window/menu
![obraz](https://github.com/intsez/Pi-hole_autoinstaller/assets/25661004/a7198bf3-c74a-4477-9e69-a66bafba90eb)

## Usage
Just download and execute the script :

```sh
wget https://raw.githubusercontent.com/intsez/Pi-hole_autoinstaller/main/Pi-hole_autoinstaller.sh
chmod +x Pi-hole_autoinstaller.sh
./Pi-hole_autoinstaller.sh
```
