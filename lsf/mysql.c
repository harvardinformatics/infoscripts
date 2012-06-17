#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

MYSQL *Mysql_Connect() {

  MYSQL     *conn;

  char *server   = "localhost";
  char *user     = "root";
  char *password = "98lsf76";
  char *database = "lsf";

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
void add_query_string_value(char *qstr,char *value) {
  
  strcat(qstr,",'");
  strcat(qstr,value);
  strcat(qstr,"'");

}
void add_query_string_noquote_value(char *qstr,char *value) {
  
  strcat(qstr,",");
  strcat(qstr,value);

}
