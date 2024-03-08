from debian:12

LABEL org.opencontainers.image.source=https://github.com/bcurnow/openvpnas
LABEL org.opencontainers.image.description="OpenVPN Access Server"
LABEL org.opencontainers.image.licenses=GPL-3.0-or-later

ARG DEBIAN_RELEASE="bookworm"
ARG DEBIAN_FRONTEND="noninteractive"

ARG OPENVPNAS_VERSION

RUN echo "*** Install dependencies ***" && \
    apt-get update && apt-get -y install --no-install-recommends \
      ca-certificates \
      gnupg \
      net-tools \
      curl && \
     echo "\n*** Download the repository key ***\n" && \
     curl --silent -o /etc/apt/trusted.gpg.d/as-repository.asc https://as-repository.openvpn.net/as-repo-public.asc && \
     echo "\n*** Install OpenVPN AS repository ***\n" && \
     echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/as-repository.asc] http://as-repository.openvpn.net/as/debian ${DEBIAN_RELEASE} main">/etc/apt/sources.list.d/openvpn-as-repo.list && \
     echo "\n*** Installing OpenVPN AS version (${OPENVPNAS_VERSION})" \
     echo "*** Ignore log messages regarding failed configuration and missing systemctl, we don't use systemd inside the container\n" && \
     apt-get update && apt-get -y install --no-install-recommends openvpn-as=${OPENVPNAS_VERSION} python3-service-identity && \
     echo "\n*** Cleaning up files ***\n" && \
     rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*  /var/lib/apt/lists/*

COPY entry-point.sh /

EXPOSE 1194/udp
EXPOSE 943/tcp
EXPOSE 443/tcp

VOLUME ["/usr/local/openvpn_as"]

ENTRYPOINT ["/entry-point.sh"]
CMD ["--nodaemon", "--umask=0077"]
