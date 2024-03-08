from debian:12

RUN apt-get update && apt-get -y install --no-install-recommends \
     ca-certificates \
     gnupg \
     net-tools \
     wget && \
     wget https://as-repository.openvpn.net/as-repo-public.asc -qO /etc/apt/trusted.gpg.d/as-repository.asc && \
     echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/as-repository.asc] http://as-repository.openvpn.net/as/debian bookworm main">/etc/apt/sources.list.d/openvpn-as-repo.list && \
     apt-get update && apt-get -y install --no-install-recommends openvpn-as python3-service-identity && \
     rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*  /var/lib/apt/lists/*

COPY entry-point.sh /

EXPOSE 1194/udp
EXPOSE 943/tcp
EXPOSE 443/tcp

VOLUME ["/usr/local/openvpn_as"]

ENTRYPOINT ["/entry-point.sh"]
CMD ["--nodaemon", "--umask=0077"]
