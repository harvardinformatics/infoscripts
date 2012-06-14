LSFINC=/lsf/7.0/include/
LSFLIB=/lsf/7.0/linux2.6-glibc2.3-x86_64/lib/
LSF_CFLAGS=-I$(LSFINC) -L$(LSFLIB) -lbat -llsf -lnsl -lm

CFLAGS= -O4 -Wall

# From mysql_config5 --clibs

MYSQL_CLIBS=-L/opt/local/lib   -L/opt/local/lib/mysql5/mysql -lmysqlclient -L/opt/local/lib -lz -lm  -L/opt/local/lib/ -lssl -lcrypto

# From mysql_config5 --cflags

MYSQL_CFLAGS=-I/opt/local/include/mysql5/mysql  -pipe -fPIC    -D_P1003_1B_VISIBLE -DSIGNAL_WITH_VIO_CLOSE -DSIGNALS_DONT_BREAK_READ -DIGNORE_SIGHUP_SIGQUIT  -DDONT_DECLARE_CXA_PURE_VIRTUAL

all: binfo eventtest

binfo: binfo.c
	gcc $(CFLAGS) $(LSF_CFLAGS) -o binfo binfo.c

eventtest: eventtest.c
	gcc $(CFLAGS) $(LSF_CFLAGS) -o eventtest eventtest.c

mysqltest: mysqltest.c
	gcc $(CFLAGS) $(MYSQL_CFLAGS) -o mysqltest mysqltest.c $(MYSQL_CLIBS)

clean:
	rm -f *.so *.o binfo eventtest
