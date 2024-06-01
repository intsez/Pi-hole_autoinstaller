## Pi-hole_autoinstaller.sh

Basic features:
* select a webserver (lighttpd or nginx)
* install DoH -  [cloudflared](https://docs.pi-hole.net/guides/dns/cloudflared/) 
* generate a [Self-signed SSL certificate](https://en.wikipedia.org/wiki/Self-signed_certificate)
* add an extra layer of security with [basic HTTP authentication](https://en.wikipedia.org/wiki/Basic_access_authentication)
* add a huge number of domains to the Pi-hole blacklist ([check it](https://raw.githubusercontent.com/intsez/Pi-hole_autoinstaller/main/conf/lists/PiHoleBlackLists.txt))

![obraz](https://github.com/intsez/Pi-hole_autoinstaller/assets/25661004/2c3d4646-bbe2-48fe-b5c4-1dd05380b590)

## The script menu
![obraz](https://github.com/intsez/Pi-hole_autoinstaller/assets/25661004/a7198bf3-c74a-4477-9e69-a66bafba90eb)

## Usage
Just download and execute the script :

```sh
wget https://raw.githubusercontent.com/intsez/Pi-hole_autoinstaller/main/Pi-hole_autoinstaller.sh
chmod +x Pi-hole_autoinstaller.sh
./Pi-hole_autoinstaller.sh
```
