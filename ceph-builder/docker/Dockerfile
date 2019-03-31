FROM debian:stretch

ENV BIN_DIR="/debs"

WORKDIR /tmp

COPY install-deps-stretch.sh /
COPY build.sh /

RUN apt update && \
	apt install -y wget python python3 && \
	chmod 755 /build.sh /install-deps-stretch.sh && \
	apt-get clean && \
	rm -fr /var/lib/apt/lists/* 
	

VOLUME ["${BIN_DIR}"]

ENTRYPOINT ["/build.sh"]
