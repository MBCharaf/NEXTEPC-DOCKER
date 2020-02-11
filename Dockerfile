#Download base image ubuntu 16.04
FROM ubuntu:16.04

# Install dependencies
RUN apt-get update && \
	apt install -y \
	sudo \
	autoconf\
	libtool\
	gcc \ 
	pkg-config \
	git \
	flex \
	bison \
	libsctp-dev \
	libgnutls28-dev \
	libgcrypt-dev \
	libssl-dev \
	libidn11-dev \
	libbson-dev \
	libmongoc-1.0-0 \
	libmongoc-dev \
	libbson-1.0-0 \
	iptables \
	libyaml-dev && \
	rm -rf /var/lib/apt/lists/*

# fetch nextepc code from git and build

RUN git clone https://github.com/nextepc/nextepc && \
    cd nextepc && \
    autoreconf -iv && \
    ./configure --prefix=`pwd`/install && \
    make -j `nproc` && \ 
    make install

# Remove old .config file:
RUN rm /nextepc/install/etc/nextepc/nextepc.conf


	
