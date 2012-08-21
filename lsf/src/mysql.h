#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define QUERY_INT    1;
#define QUERY_FLOAT  2;
#define QUERY_STRING 3;

typedef struct _Mytime {
  time_t *time;
  int year;
  int month;
  int mday;
  int wday;
  int hour;
  int min;
  int sec;

  char   *mysql_str;
} Mytime;



extern MYSQL *Mysql_Connect();

extern void  add_query_int_value(char *qstr,int value);
extern void  add_query_float_value(char *qstr,float value);
extern void  add_query_string_value(char *qstr,char *value,MYSQL *conn);
extern void  add_query_string_noquote_value(char *qstr,char *value);
extern Mytime *time_to_unixtime_value(time_t time);
extern char *Mysql_Escape_String(MYSQL *conn,char *str);
