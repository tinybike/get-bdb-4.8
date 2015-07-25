#include <assert.h>
#include <db_cxx.h>

int main(int argc, char *argv[])
{
    assert(DB_VERSION_MAJOR == 4 && DB_VERSION_MINOR == 8);
    return 0;
}
