#include <cstdio>
#include <assert.h>
#include <db_cxx.h>

int main(int argc, char *argv[])
{
    printf("Berkeley DB version check: %d.%d\n", DB_VERSION_MAJOR, DB_VERSION_MINOR);
    assert(DB_VERSION_MAJOR == 4 && DB_VERSION_MINOR == 8);
    return 0;
}
