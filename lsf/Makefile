LSFINC=/lsf/7.0/include/
LSFLIB=/lsf/7.0/linux2.6-glibc2.3-x86_64/lib/
LSF_CFLAGS=-I$(LSFINC) -L$(LSFLIB) -lbat -llsf -lnsl -lm

CFLAGS= -O4 -Wall

all: binfo eventtest

binfo: binfo.c
	gcc $(CFLAGS) $(LSF_CFLAGS) -o binfo binfo.c

eventtest: eventtest.c
	gcc $(CFLAGS) $(LSF_CFLAGS) -o eventtest eventtest.c

clean:
	rm -f *.so *.o binfo eventtest
