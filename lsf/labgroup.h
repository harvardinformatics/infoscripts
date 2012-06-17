#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "utils.h"
#include "uthash.h"

typedef struct _Labgroup {
  int id;
  char name[100];
  UT_hash_handle hh;

} Labgroup;


typedef struct _User {
  int  id;             /* This is the internal id in the mysql db */
  char name[100];      /* This is the key string */        
  Labgroup *groups[100];
  UT_hash_handle hh ;  /* Makes this structure hashable */

} User;


extern User      *User_Line_Parse  (char *line);
extern void       User_Labgroup_Mysql_Update(MYSQL *conn, User *user,Labgroup **groups);

extern User      *User_Mysql_Get   (MYSQL *conn,char *user_name);
extern User      *User_Mysql_Add   (MYSQL *conn,char *user_name);
extern int        User_Mysql_Update(MYSQL *conn,char *user_name);

extern Labgroup  *Labgroup_Mysql_Get(MYSQL *conn,char *labgroup_name);
extern Labgroup  *Labgroup_Mysql_Add(MYSQL *conn,char *labgroup_name);
extern int        Labgroup_Mysql_Update(MYSQL *conn,char *labgroup_name);

extern User      *User_Create(char *name,int id);
extern void       User_Free  (User *user);
extern void       User_Print (User *user);

extern Labgroup  *Labgroup_Create(char *name,int id);
extern void       Labgroup_Free  (Labgroup *group);
extern void       Labgroup_Print (Labgroup *group);

extern void       add_user   (User *s,char *name);
extern User      *find_user  (char *name);
extern void       delete_user(User *user);
