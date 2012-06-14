#include "uthash.h"
#include <stdio.h>
#include <time.h>
#include <stdlib.h> 
#include <string.h>

typedef struct _User {
  int id;            /* we'll use this field as the key */
  char name[10];             
  UT_hash_handle hh; /* makes this structure hashable */
} User;

User *users = NULL;  /* Must init to null */

void  add_user(User *s);
User *find_user(int user_id);
void  delete_user(User *user);
      
void add_user(User *s) {
  HASH_ADD_INT( users, id, s );    
}

User *find_user(int user_id) {
  User *s;
  
  HASH_FIND_INT( users, &user_id, s );  
  return s;
}

void delete_user(User *user) {
  HASH_DEL( users, user);  
}

int main(int argc, char *argv[]) {

  User *tmp;
  User *tmp2;

  tmp = (User *)malloc(sizeof(User));

  tmp->id = 1;
  strcpy(tmp->name,"Michele");
  
  add_user(tmp);

  tmp2 = find_user(2);

  if (tmp2) {
    printf("User %s\n",tmp2->name);
  } else {
    printf("No user found for 2\n");
  }
    
  return 0;
}
