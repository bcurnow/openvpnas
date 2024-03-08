# openvpnas
A containerized version of OpenVPN Access Server

# How to get the latest version number of OpenVPN AS
`curl -sX GET http://as-repository.openvpn.net/as/debian/dists/bookworm/main/binary-amd64/Packages.gz | gunzip -c | grep -A 7 -m 1 "Package: openvpn-as" | awk -F ": " '/Version/{print $2;exit}'`
