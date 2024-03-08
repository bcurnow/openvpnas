from debian:12

ARG DEBIAN_RELEASE="bookworm"
ARG DEBIAN_FRONTEND="noninteractive"



RUN echo "*** Install dependencies ***" && \
    apt-get update && apt-get -y install --no-install-recommends \
      ca-certificates \
      gnupg \
      net-tools \
      curl && \
     echo "*** Download the repository key ***" && \
     curl --silent -o /etc/apt/trusted.gpg.d/as-repository.asc https://as-repository.openvpn.net/as-repo-public.asc && \
     echo "*** Install OpenVPN AS repository ***" && \
     echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/as-repository.asc] http://as-repository.openvpn.net/as/debian ${DEBIAN_RELEASE} main">/etc/apt/sources.list.d/openvpn-as-repo.list && \
     echo "*** Determining current version ***" && \
     OPENVPNAS_VERSION=$(curl -sX GET http://as-repository.openvpn.net/as/debian/dists/${DEBIAN_RELEASE}/main/binary-amd64/Packages.gz | gunzip -c \
       |grep -A 7 -m 1 "Package: openvpn-as" | awk -F ": " '/Version/{print $2;exit}') && \
     echo "*** OpenVPN AS Version: ${OPENVPNAS_VERSION} ***" && \
     echo "Installing OpenVPN AS, ignore log messages regarding failed configuration and missing systemctl, we don't use systemd inside the container" && \
     apt-get update && apt-get -y install --no-install-recommends openvpn-as python3-service-identity && \
     echo "*** Cleaning up files ***" && \
     rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*  /var/lib/apt/lists/*

COPY entry-point.sh /

EXPOSE 1194/udp
EXPOSE 943/tcp
EXPOSE 443/tcp

VOLUME ["/usr/local/openvpn_as"]

ENTRYPOINT ["/entry-point.sh"]
CMD ["--nodaemon", "--umask=0077"]
