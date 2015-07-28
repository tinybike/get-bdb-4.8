#!/bin/bash
# Installs Berkeley DB 4.8.
#
# Syntax:
#   ./install.sh /path/to/bitcoin
#
# If no path is provided, BDB 4.8 is installed locally to a new bdb/ folder.
#
# @author Jack Peterson (jack@tinybike.net)

set -e
trap "exit" INT

BLUE='\033[1;34m'
RED='\033[1;31m'
CYAN='\033[0;36m'
NC='\033[0m'

startdir=$(pwd)
echo -e "\033[0;34mLogging to $startdir/log${NC}"

if [ -n "$1" ]; then
    target=$1/src
else
    target=$(pwd)
fi
if [ -f "log" ]; then
    rm log
fi

cd "$target"

if [ ! -d "bdb" ]; then

    mkdir -p bdb

    bdbtargz="bdb-4.8.tar.gz"

    if [ ! -f "$startdir/$bdbtargz" ]; then

        bdburl="http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz"

        echo -e "${RED}Downloading $bdburl...${NC}"
        wget -O $startdir/$bdbtargz $bdburl

    fi

    echo -e "${BLUE}Installing Berkeley DB 4.8 to $target/bdb...${NC}"
    mkdir -p bdb

    echo -e "${CYAN}  - unpack $bdbtargz -> ${PWD##*/}/bdb${NC}"
    tar -xvf $startdir/$bdbtargz -C bdb --strip-components=1 >>$startdir/log 2>&1

    cd bdb/build_unix
    mkdir -p build

    export BDB_PREFIX=$(pwd)/build

    echo -e "${CYAN}  - dist/configure${NC}"
    ../dist/configure --disable-shared --enable-cxx --with-pic --prefix=$BDB_PREFIX >>$startdir/log 2>&1

    echo -e "${CYAN}  - install -> ${PWD##*/}/build${NC}"
    make install >>$startdir/log 2>&1

    cd ../..
    echo -e "${RED}Done.${NC}"

else

    export BDB_PREFIX=$(pwd)/bdb/build_unix/build

    echo -e "${RED}Found local Berkeley DB: $BDB_PREFIX${NC}"

fi

cd "$startdir"

echo -e "${BLUE}Checking Berkeley DB version...${NC}"
g++ version.cpp -I${BDB_PREFIX}/include/ -L${BDB_PREFIX}/lib/ -o version
./version

if [ -f "$target/../configure.ac" ] || [ -f "$target/../configure.in" ]; then

    cd "$target/.."

    echo -e "${BLUE}Creating configure script...${NC}"
    if [ ! -f "aclocal.m4" ]; then
        ./autogen.sh >>$startdir/log 2>&1
    fi
    autoreconf --install --force --prepend-include=${BDB_PREFIX}/include/ >>$startdir/log 2>&1

    echo -e "${BLUE}Configuring...${NC}"
    ./configure CPPFLAGS="-I${BDB_PREFIX}/include/" LDFLAGS="-L${BDB_PREFIX}/lib/" >>$startdir/log 2>&1

    cd "$startdir"
    echo -e "${RED}Done.${NC}"

fi
