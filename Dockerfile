from debian:12

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
     echo "\n*** Determining latest OpenVPN AS version ***\n" && \
     OPENVPNAS_LATEST_VERSION=$(curl -sX GET http://as-repository.openvpn.net/as/debian/dists/${DEBIAN_RELEASE}/main/binary-amd64/Packages.gz | gunzip -c \
       |grep -A 7 -m 1 "Package: openvpn-as" | awk -F ": " '/Version/{print $2;exit}') && \
     OPENVPNAS_LATEST_SHORT_VERSION=$(echo "${OPENVPNAS_LATEST_VERSION}" | cut -f 1 -d "-") && \
     echo "\n*** Latest OpenVPN AS Version: ${OPENVPNAS_LATEST_SHORT_VERSION} (${OPENVPNAS_LATEST_VERSION}) ***\n" && \
     OPENVPNAS_SHORT_VERSION=$(echo "${OPENVPNAS_LATEST_VERSION}" | cut -f 1 -d "-") && \
     OPENVPNAS_VERSION_MSG="OpenVPN AS version ${OPENVPNAS_SHORT_VERSION} (${OPENVPNAS_VERSION})" && \
     if [ -z ${OPENVPNAS_VERSION} ] \
     then \
         OPENVPNAS_VERSION=${OPENVPNAS_LATEST_VERSION} \
         OPENVPNAS_SHORT_VERSION=${OPENVPNAS_LATEST_SHORT_VERSION} \
         echo "\n*** Installing OpenVN AS latest version ${OPENVPNAS_SHORT_VERSION} (${OPENVPNAS_VERSION})" \
     else \
         echo "\n*** Installing OpenVN AS version ${OPENVPNAS_SHORT_VERSION} (${OPENVPNAS_VERSION})" \
     fi && \
     echo "\n*** Ignore log messages regarding failed configuration and missing systemctl, we don't use systemd inside the container\n" && \
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
