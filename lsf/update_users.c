#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "labgroup.h"
#include "mysql.h"

int main(int argc, char *argv[]){

  FILE      *user_fp;
  MYSQL     *conn;
  char      *userfile = argv[1];

  if (argc != 2) {
    printf("Usage: %s <userfile>\n", argv[0]);
    exit(-1);
  }
    
  user_fp = fopen(userfile, "r");

  if (user_fp == NULL) {
    perror(userfile);
    exit(-1);
  }

  conn = Mysql_Connect();

  char  *line = NULL;
  User  *user;
  int    i;

  while ((line = read_line(user_fp)) && line != NULL) {

    user     = User_Line_Parse(line);


    User_Labgroup_Mysql_Update(conn,user,user->groups);

    printf("\n");
    User_Print(user);

    i = 0;

    while (user->groups[i] != NULL) {
      Labgroup_Print(user->groups[i]);
      i++;
    }
    
    free(line);

  }

  printf("\nLoaded/updated users and groups\n");

  return 0;
}

