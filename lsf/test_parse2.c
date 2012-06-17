/* Simple C program that connects to MySQL Database server*/

#include<stdio.h>
#include <stdlib.h>
#include <string.h>
#include "uthash.h"
#include <time.h>

typedef struct _User {
  int id;            /* This is the internal id in the mysql db */
  char name[100];     /* This is the key string */        
  UT_hash_handle hh; /* makes this structure hashable */
} User;

User *users = NULL;  /* Must init to null */

void  add_user(User *s,char *name);
User *find_user(char *name);
void  delete_user(User *user);
      
User *User_Create(char *name,int id);
void  User_Free  (User *user);
void  User_Print (User *user);

int main(int argc, char *argv[]){

  User *tmp1;
  User *tmp2;
  User *tmp3;

  tmp1 = User_Create("Michele",1);
  tmp2 = User_Create("Pog",2);

  User_Print(tmp1);
  User_Print(tmp2);

  add_user(tmp1,"name");

  tmp3 = find_user("Michele");

  if (tmp3) {
    printf("User %s %d\n",tmp3->name,tmp3->id);
  } else {
    printf("No user found for Michele\n");
  }

  return 0;
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

User *User_Create(char *name,int id) {
  User *user;

  user       = (User *)malloc(sizeof(User));
  //user->name = (char *)malloc((strlen(name)+1)*sizeof(char));
  user->id   = id;
  strcpy(user->name,name);

  return user;
}

void User_Free(User *user) {
  free(user->name);
  free(user);
}

void User_Print(User *user) {

  char *tmpname = "";
  char  tmpid   = -1;

  if (user->name) {
    tmpname = user->name;
  }
  if (user->id) {
    tmpid = user->id;
  }
  printf("User %s %d\n",tmpname,tmpid);

}
