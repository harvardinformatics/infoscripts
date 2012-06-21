#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "utils.h"
#include "uthash.h"
#include "labgroup.h"

User  *users = NULL;   /* The user hash */

User *User_Line_Parse(char *line) {
  char     **words;
  char      *name;
  User      *user;

  int    i;

  words   = read_words(0,line);
  name    = words[0];
  user    = User_Create(name,-1);
  
  int    gcount = 0;

  i = 2;

  while (words[i] != NULL) {
    char     *groupname = words[i];
    Labgroup *group     = Labgroup_Create(groupname,-1);

    user->groups[gcount] = group;

    gcount++;
    i++;
      
  }

  user->groups[gcount] = NULL;

  i = 0;
  
  while (words[i] != NULL) {
    free(words[i]);
    i++;
  }
  
  return user;
}

int User_Mysql_Update(MYSQL *conn,char *name) {
  User *user;
  int   id;

  user  = User_Mysql_Get(conn,name);
    
  if (user == NULL) {
    user= User_Mysql_Add(conn,name);
  }

  id = user->id;

  User_Free(user);

  return id;
}
int Labgroup_Mysql_Update(MYSQL *conn, char *name) {
  Labgroup *group;
  int       id;

  group  = Labgroup_Mysql_Get(conn,name);
  

  if (group == NULL) {
    group = Labgroup_Mysql_Add(conn,name);
  }

  id = group->id;

  Labgroup_Free(group);

  return id;
}

void User_Labgroup_Mysql_Update(MYSQL *conn, User *user,Labgroup **groups) {
  char *qstr;
  char  str[100];
  
  int id = User_Mysql_Update(conn,user->name);
  
  user->id = id;

  sprintf(str,"%d",user->id);
  
  qstr = (char *)malloc(100*sizeof(char));

  strcpy(qstr,"delete from user_group where user_internal_id = ");
  strcat(qstr,str);

  if (mysql_query(conn,qstr)){
    fprintf(stderr,"%s\n",mysql_error(conn));
    exit(1);
  } 

  free(qstr);


  
  int        i      = 0;

  while (groups[i] != NULL) {
    qstr = (char *)malloc(300*sizeof(char));

    int gid  = Labgroup_Mysql_Update(conn,groups[i]->name);

    groups[i]->id = gid;

    char gstr[100];
    char ustr[100];

    sprintf(ustr,"%d",user->id);
    sprintf(gstr,"%d",gid);

    strcpy(qstr,"insert into user_group values(");
    strcat(qstr,ustr);
    strcat(qstr,",");
    strcat(qstr,gstr);

    user->groups[i] = groups[i];
    i++;

    strcat(qstr,")");

    if (mysql_query(conn,qstr)){
      fprintf(stderr,"%s\n",mysql_error(conn));
      exit(1);
    } 

    free(qstr);
  }


}

User *User_Mysql_Get(MYSQL *conn,char *username) {
  MYSQL_ROW row;
  MYSQL_RES *res;

  char *qstr;
  User *user;

  int id;
  int num_fields;

  qstr = (char *)malloc(200*sizeof(char));

  strcpy(qstr,"select user_internal_id from user where user_name = '");
  strcat(qstr,username);
  strcat(qstr,"'");

  if (mysql_query(conn,qstr)){
    fprintf(stderr,"%s\n",mysql_error(conn));
    exit(1);
  } 

  free(qstr);
  res = mysql_use_result(conn);

  if (res) {
    id    = -1;
    num_fields = mysql_num_fields(res);

    while((row = mysql_fetch_row(res))!= NULL) {
      id = atoi(row[0]);
    }

    if (id == -1) {
      return NULL;
    }

    mysql_free_result(res);
    
    user = User_Create(username,id);

    return user;
  }
  return NULL;
}


Labgroup  *Labgroup_Mysql_Get(MYSQL *conn,char *labgroup_name) {
  MYSQL_RES *res;
  MYSQL_ROW  row;
  
  char      *qstr;

  int id = -1;
  int num_fields;

  Labgroup *group = NULL;

  qstr = (char *)malloc(200*sizeof(char));

  strcpy(qstr,"select labgroup_internal_id from labgroup where labgroup_name = '");
  strcat(qstr,labgroup_name);
  strcat(qstr,"'");
  
  if (mysql_query(conn,qstr)){
    fprintf(stderr,"%s\n",mysql_error(conn));
    exit(1);
  } 

  free(qstr);
  res = mysql_use_result(conn);

  if (res) {
    id    = -1;
    num_fields = mysql_num_fields(res);

    while((row = mysql_fetch_row(res))!= NULL) {
      id = atoi(row[0]);
    }

    mysql_free_result(res);
   
  }

  if (id != -1) {
    group = Labgroup_Create(labgroup_name,id);
  } 
  return group;
}

Labgroup *Labgroup_Mysql_Add(MYSQL *conn, char *labgroup_name) {
  MYSQL_RES *res;

  char *qstr;

  qstr = (char *)malloc(200*sizeof(char));
  
  strcpy(qstr,"insert into labgroup values(NULL,'");
  strcat(qstr,labgroup_name);
  strcat(qstr,"')");
  
  if (mysql_query(conn,qstr)){
    fprintf(stderr,"%s\n",mysql_error(conn));
    exit(1);
  } 
  
  res = mysql_use_result(conn);
  
  mysql_free_result(res);
  free(qstr);

  return Labgroup_Mysql_Get(conn,labgroup_name);
}

User *User_Create(char *name,int id) {
  User *user;

  user       = (User *)malloc(sizeof(User));
  user->id   = id;

  strcpy(user->name,name);

  user->name[strlen(name)] = '\0';

  user->groups[0] = NULL;

  return user;
}

void User_Free(User *user) {
  if (user) {
    free(user);
  }
}

void User_Print(User *user) {

  printf("User %s %d\n",user->name,user->id);

}
Labgroup *Labgroup_Create(char *name,int id) {
  Labgroup *group;

  group       = (Labgroup *)malloc(sizeof(Labgroup));
  group->id   = id;

  strcpy(group->name,name);
  
  group->name[strlen(name)] = '\0';
  return group;
}

void Labgroup_Free(Labgroup *group) {
  if (group) {
    free(group);
  }
}
void User_Labgroup_Free(User *user) {

  int i = 0;
  
  while (user->groups[i] != NULL) {
    Labgroup_Free(user->groups[i]);
    i++;
  }

  User_Free(user);


}

void Labgroup_Print(Labgroup *group) {

  printf("Group %s %d\n",group->name,group->id);

}

User *User_Mysql_Add(MYSQL *conn, char *username) {
  MYSQL_RES *res;
  char      *qstr;

  qstr = (char *)malloc(200*sizeof(char));
  
  strcpy(qstr,"insert into user values(NULL,'");
  strcat(qstr,username);
  strcat(qstr,"')");
  
  if (mysql_query(conn,qstr)){
    fprintf(stderr,"%s\n",mysql_error(conn));
    exit(1);
  } 
  
  res = mysql_use_result(conn);
  
  mysql_free_result(res);
  free(qstr);

  return User_Mysql_Get(conn,username);
}
void add_user(User *s,char *name) {
  HASH_ADD_STR( users, name, s );    
}

User *find_user(char *name) {
  User *s;
  
  HASH_FIND_STR( users, name, s );  
  return s;
}

void delete_user(User *user) {
  HASH_DEL( users, user);  
}

