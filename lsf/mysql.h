#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define QUERY_INT    1;
#define QUERY_FLOAT  2;
#define QUERY_STRING 3;

extern MYSQL *Mysql_Connect();

extern void  add_query_int_value(char *qstr,int value);
extern void  add_query_float_value(char *qstr,float value);
extern void  add_query_string_value(char *qstr,char *value);
extern void  add_query_string_noquote_value(char *qstr,char *value);

