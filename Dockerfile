FROM debian:trixie AS runner

LABEL Description="Docker image for NS-3 Network Simulator"

ARG VERSION=3.41

# Timezone things?
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# System packages
# Required: build-essetial through wget
# Optional for ns3 features: libsqlite3-dev through libgsl-dev
#
# Optional, but probably useful:
# tcpdump: to read pcap files
# cccache: to speed up the build
# clang-format, clang-tidy: linters
# gdb, valgrind: to debug
#
# Quality of life deps: vim, less, git
#
# Finally, clean up the cache to save some space
RUN apt-get update && apt-get install -y \
#    build-essential \
    g++ \
    python3 \
    cmake \
    wget \
    bzip2 \
    libsqlite3-dev \
    libeigen3-dev \
    libgsl-dev \
    tcpdump \
    ccache \
#    clang-format \
#    clang-tidy \
#    gdb \
#    valgrind \
    vim \
    less \
#    git \
     && rm -rf /var/lib/apt/lists/*

# Create a user
RUN mkdir -p /ns3

WORKDIR /tmp

# Get sources
RUN wget https://www.nsnam.org/releases/ns-allinone-$VERSION.tar.bz2
RUN tar xfj ns-allinone-$VERSION.tar.bz2
RUN rm ns-allinone-$VERSION.tar.bz2

# We don't need this anymore
RUN apt-get -y purge wget bzip2

# Move to somewhere nicer
RUN mv ./ns-allinone-$VERSION/ns-$VERSION /ns3/$VERSION
WORKDIR /ns3/$VERSION

# Configure
RUN ./ns3 configure
#--enable-examples --enable-tests

# Build
RUN ./ns3 build

# Test
#RUN ./test.py

CMD ["bash"]
