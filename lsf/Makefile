
# Remember export LD_LIBRARY_PATH=/home/mclamp/src/mysql/lib

LSFINC=/lsf/7.0/include/
LSFLIB=/lsf/7.0/linux2.6-glibc2.3-x86_64/lib/
LSF_CFLAGS=-I$(LSFINC) -L$(LSFLIB) -lbat -llsf -lnsl -lm

CFLAGS= -g -O4 -Wall

MYSQL_CFLAGS=`mysql_config --cflags`
MYSQL_CLIBS=`mysql_config --libs`


all: binfo eventtest

binfo: binfo.c
	gcc $(CFLAGS) $(LSF_CFLAGS) -o binfo binfo.c

eventtest: eventtest.c
	gcc $(CFLAGS) $(LSF_CFLAGS) -o eventtest eventtest.c

mysqltest: mysqltest.c
	gcc $(CFLAGS) $(MYSQL_CFLAGS) -o mysqltest mysqltest.c $(MYSQL_CLIBS)

mysql_usertest: mysql_usertest.c
	gcc $(CFLAGS) $(MYSQL_CFLAGS) -o mysql_usertest mysql_usertest.c $(MYSQL_CLIBS)

mysql_loadusers: mysql_loadusers.c
	gcc $(CFLAGS) $(MYSQL_CFLAGS) -o mysql_loadusers mysql_loadusers.c $(MYSQL_CLIBS)

uthashtest: uthashtest.c
	gcc $(CFLAGS) -o uthashtest uthashtest.c

clean:
	rm -f *.so *.o binfo eventtest
