
# Remember export LD_LIBRARY_PATH=/home/mclamp/src/mysql/lib

LSFINC=/lsf/7.0/include/
LSFLIB=/lsf/7.0/linux2.6-glibc2.3-x86_64/lib/
LSF_CFLAGS=-I$(LSFINC) -L$(LSFLIB) -lbat -llsf -lnsl -lm

CFLAGS= -O4 -Wall

MYSQL_CFLAGS=`mysql_config --cflags`
MYSQL_CLIBS=`mysql_config --libs`

BINDIR=../bin

all: import_lsf_log update_users uthashtest mysqltest mysqltest mysql_usertest binfo

import_lsf_log: import_lsf_log.c mysql.o utils.o labgroup.o
	gcc $(CFLAGS) $(LSF_CFLAGS) $(MYSQL_CFLAGS) -o $(BINDIR)/import_lsf_log import_lsf_log.c mysql.o utils.o labgroup.o $(MYSQL_CLIBS)

update_users: update_users.c labgroup.o utils.o mysql.o
	gcc $(CFLAGS) $(MYSQL_CFLAGS) -o $(BINDIR)/update_users update_users.c labgroup.o utils.o mysql.o $(MYSQL_CLIBS) 

labgroup.o: labgroup.c labgroup.h
	gcc -c $(CFLAGS) $(MYSQL_CFLAGS) labgroup.c

utils.o: utils.c utils.h
	gcc -c $(CFLAGS) $(MYSQL_CFLAGS) utils.c

mysql.o: mysql.c mysql.h
	gcc -c $(CFLAGS) $(MYSQL_CFLAGS) mysql.c

binfo: binfo.c
	gcc $(CFLAGS) $(LSF_CFLAGS) -o $(BINDIR)/binfo binfo.c

eventtest: eventtest.c
	gcc $(CFLAGS) $(LSF_CFLAGS) -o $(BINDIR)/eventtest eventtest.c

mysqltest: mysqltest.c
	gcc $(CFLAGS) $(MYSQL_CFLAGS) -o $(BINDIR)/mysqltest mysqltest.c $(MYSQL_CLIBS)

mysql_usertest: mysql_usertest.c
	gcc $(CFLAGS) $(MYSQL_CFLAGS) -o $(BINDIR)/mysql_usertest mysql_usertest.c $(MYSQL_CLIBS)

uthashtest: uthashtest.c
	gcc $(CFLAGS) -o $(BINDIR)/uthashtest uthashtest.c

clean:
	rm -f *.so *.o binfo eventtest $(BINDIR)/*
