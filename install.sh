#!/bin/bash
# Installs Berkeley DB 4.8.
#
# Syntax:
#   ./install.sh /path/to/bitcoin
#
# If no path is provided, BDB 4.8 installs to src/bdb.
#
# @author Jack Peterson (jack@tinybike.net)

set -e
trap "exit" INT

startdir=$(pwd)

if [ -n "$1" ]; then
    target=$1
else
    target=$(pwd)
    mkdir -p src
fi

echo "Installing Berkeley DB 4.8 to $target/src/bdb..."

cd "$target/src"

if [ ! -d "bdb" ]; then
    if [ ! -f "$startdir/bdb-4.8.tar.gz" ]; then
        wget -O $startdir/bdb-4.8.tar.gz http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz
    fi
    mkdir -p bdb

    echo " - unpack bdb-4.8.tar.gz -> src/bdb"
    tar -xvf $startdir/bdb-4.8.tar.gz -C bdb --strip-components=1 > /dev/null 2>&1

    cd bdb/build_unix
    mkdir -p build

    export BDB_PREFIX=$(pwd)/build

    echo " - dist/configure"
    ../dist/configure --disable-shared --enable-cxx --with-pic --prefix=$BDB_PREFIX > /dev/null 2>&1

    echo " - install -> src/bdb/build_unix/build"
    make install > /dev/null 2>&1

    cd ../..
    echo "Done."
else
    export BDB_PREFIX=$(pwd)/bdb/build_unix/build

    echo "Found local Berkeley DB: $BDB_PREFIX"
fi

cd "$startdir"
g++ version.cpp -I${BDB_PREFIX}/include/ -L${BDB_PREFIX}/lib/ -o version
./version

if [ -f "$target/configure.ac" ] || [ -f "$target/configure.in" ]; then
    cd "$target"

    echo "Creating configure script..."
    autoreconf --install --force --prepend-include=${BDB_PREFIX}/include/ > /dev/null 2>&1

    echo "Running configure..."
    ./configure CPPFLAGS="-I${BDB_PREFIX}/include/" LDFLAGS="-L${BDB_PREFIX}/lib/" > /dev/null 2>&1

    cd "$startdir"
    echo "Done."
fi
