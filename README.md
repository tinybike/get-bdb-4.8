Berkeley DB 4.8 installer
=========================

Bitcoin requires Berkeley DB 4.8 to be installed for portable wallets.  get-bdb-4.8 is a simple script that [downloads](http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz) and installs BDB 4.8.

Usage
-----

    $ ./install.sh /path/to/bitcoin

BDB 4.8 is installed to the `src/bdb` folder in the path specified (in this case, `/path/to/bitcoin/src/bdb`).  If no path is provided, BDB 4.8 installs locally to a new `bdb` folder.

If libtool is installed (and a `configure.ac` or `configure.in` file is present), the script will run `autogen.sh` (if needed), then configure the target directory to use the new BDB path:

    $ autoreconf --install --force --prepend-include=/path/to/bitcoin/src/bdb/build_unix/build/include/

    $ ./configure CPPFLAGS="-I/path/to/bitcoin/src/bdb/build_unix/build/include/" LDFLAGS="-L/path/to/bitcoin/src/bdb/build_unix/build/lib/"
