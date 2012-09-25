#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "mysql.h"

MYSQL *Mysql_Connect() {

  MYSQL     *conn;

  char *server   = "localhost";
  char *user     = "mysql";
  char *password = "xxxxxxx";
  char *database = "lsf2";

  conn =  mysql_init(NULL);
  
  if (!mysql_real_connect(conn,
			  server,
			  user, 
			  password, 
			  database,
			  0, 
			  NULL,
			  0)){
    
    fprintf(stderr,"%s\n",mysql_error(conn));
    exit(1);
    
  }

  return conn;
}

char *Mysql_Escape_String(MYSQL *conn,char *str) {
  char *esc_str = (char *)malloc((strlen(str)*2+1)*sizeof(char));

  mysql_real_escape_string(conn,esc_str,str,strlen(str));

  return esc_str;
}

Mytime *time_to_unixtime_value(time_t time) {
  char *str;

  Mytime *mytime = (Mytime *)malloc(sizeof(Mytime));

  // First the from_unixtime string
  str  = (char *)malloc(40*sizeof(char));
  strcpy(str,"from_unixtime(");

  char *tmp_str = (char *)malloc(26*sizeof(char));;

  sprintf(tmp_str,"%ld",time);
  tmp_str[24] = '\0';
  strcat(str, tmp_str);
  strcat(str,")");

  mytime->mysql_str = (char *)malloc((strlen(str)+1)*sizeof(char));
  strcpy(mytime->mysql_str,str);

  // Now convert into Y/M/D etc
  struct tm *newtime = localtime(&time);

  mytime->year  = newtime->tm_year;
  mytime->month = newtime->tm_mon;
  mytime->mday  = newtime->tm_mday;
  mytime->hour  = newtime->tm_hour;
  mytime->sec   = newtime->tm_sec;
  mytime->wday  = newtime->tm_wday;

  return mytime;
}

void add_query_int_value(char *qstr,int value) {

  char valstr[100];
  
  sprintf(valstr,"%d",value);

  strcat(qstr,",");
  strcat(qstr,valstr);
}
void add_query_float_value(char *qstr,float value) {

  char valstr[100];
  
  sprintf(valstr,"%f",value);
  strcat(qstr,",");
  strcat(qstr,valstr);

}
void add_query_string_value(char *qstr,char *value,MYSQL *conn) {
  char *newval = Mysql_Escape_String(conn,value);
 
  strcat(qstr,",'");
  strcat(qstr,newval);
  strcat(qstr,"'");

}
void add_query_string_noquote_value(char *qstr,char *value) {
  
  strcat(qstr,",");
  strcat(qstr,value);

}
