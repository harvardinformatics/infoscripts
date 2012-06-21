#include <stdio.h>
#include <lsf/lsf.h>
#include <lsf/lsbatch.h>

void main(int c, char* argv[]) {
    char     *clustername;

    clustername = ls_getclustername();
    if (clustername == NULL) {
        ls_perror("ls_getclustername");
        exit(-1);
    }

    printf("My cluster name is: <%s>\n", clustername);


    exit(0);
}

