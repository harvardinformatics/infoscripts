#include "uthash.h"
#include <stdio.h>
#include <time.h>
#include <stdlib.h> 
#include <string.h>

typedef struct _User {
  int id;            /* This is the internal id in the mysql db */
  char name[10];     /* This is the key string */        
  UT_hash_handle hh; /* makes this structure hashable */
} User;

User *users = NULL;  /* Must init to null */

void  add_user(User *s);
User *find_user(char *name);
void  delete_user(User *user);
      
void add_user(User *s) {
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

int main(int argc, char *argv[]) {

  User *tmp1;
  User *tmp2;

  tmp1 = (User *)malloc(sizeof(User));

  tmp1->id = 1;
  strcpy(tmp1->name,"Michele");
  
  add_user(tmp1);

  tmp2 = find_user("Michele");

  if (tmp2) {
    printf("User %s %d\n",tmp2->name,tmp2->id);
  } else {
    printf("No user found for 2\n");
  }
    
  return 0;
}
