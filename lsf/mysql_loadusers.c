/* Simple C program that connects to MySQL Database server*/

#include<mysql.h>
#include<stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct _User {
  int id;            /* This is the internal id in the mysql db */
  char name[10];     /* This is the key string */        
  /*  UT_hash_handle hh;  makes this structure hashable */
} User;

char **read_words(int verbose,char *str);
char  *read_line(FILE *file);
char  *next_field(char *str, int *pos);
User  *get_user_by_username(MYSQL *conn,char *username);
User  *add_user_by_username(MYSQL *conn,char *username);
int    get_labgroup_by_labgroup_name(MYSQL *conn,char *labgroup_name);
int    add_labgroup_by_labgroup_name(MYSQL *conn,char *labgroup_name);
void update_user_and_labgroup(MYSQL *conn, int user, int *group);
int main(int argc, char *argv[]){

  FILE      *fp;
  MYSQL     *conn;
  char      *server   = "localhost";
  char      *user     = "root";
  char      *password = "98lsf76";
  char      *database = "lsf";
  char      *userfile = argv[1];

  if (argc != 2) {
    printf("Usage: %s <userfile>\n", argv[0]);
    exit(-1);
  }
    
  fp = fopen(userfile, "r");

  if (fp == NULL) {
    perror(userfile);
    exit(-1);
  }
  
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

  char **words;
  char  *line;
  char  *username;
  User  *userobj;

  int group;

  line = NULL;

  while ((line = read_line(fp)) && line != NULL) {
    printf("Line %s\n",line);
    words = read_words(0,line);
    
    username = words[0];
    
    userobj = get_user_by_username(conn,username);
    
    if (userobj == NULL) {
      userobj = add_user_by_username(conn,username);
    } else {
      printf("User %d\n",userobj->id);
    }

    int i = 2;

    int *groups;

    groups     = (int *)malloc(100*sizeof(int));
    int gcount = 0;
    
    while (words[i] != NULL) {
      printf("Group %s\n",words[i]);
      
      group = get_labgroup_by_labgroup_name(conn,words[i]);
      printf("Group %d\n",group);

      if (group == -1) {
	group = add_labgroup_by_labgroup_name(conn,words[i]);
	printf("Got group %d\n",group);
      }

      if (gcount > 100) {
	groups = (int *)realloc(groups,sizeof(groups)*(gcount+100));
      }
      groups[gcount] = group;


      gcount++;
      i++;
      
    }
    groups[gcount] = -1;

    update_user_and_labgroup(conn,userobj->id,groups);

    // Should free the individual words here - but this breaks!
    free(groups);
    free(words);
  }
  
  mysql_close(conn); 
  
  return 1;
}

void update_user_and_labgroup(MYSQL *conn, int user, int *group) {
  MYSQL_RES *res;
  MYSQL_ROW  row;

  char str[100];
  sprintf(str,"%d",user);
  char *qstr;
  
  qstr = (char *)malloc(100*sizeof(char));

  strcpy(qstr,"delete from user_group where user_internal_id = ");
  strcat(qstr,str);

  printf("Query is %s\n",qstr);

  if (mysql_query(conn,qstr)){
    fprintf(stderr,"%s\n",mysql_error(conn));
    exit(1);
  } 

  free(qstr);

  qstr = (char *)malloc(300*sizeof(char));

  
  while (*group != -1) {
    char gstr[100];
    char ustr[100];
    sprintf(gstr,"%d",*group);
    sprintf(ustr,"%d",user);
    strcpy(qstr,"insert into user_group values(");
    strcat(qstr,ustr);
    strcat(qstr,",");
    strcat(qstr,gstr);
    group++;
  }
  strcat(qstr,")");

  printf("Query is %s\n",qstr);

  if (mysql_query(conn,qstr)){
    fprintf(stderr,"%s\n",mysql_error(conn));
    exit(1);
  } 
  free(qstr);
}

User *get_user_by_username(MYSQL *conn,char *username) {
  MYSQL_RES *res;
  MYSQL_ROW row;
  
  char *qstr;
  User *user;

  int id;
  int num_fields;

  qstr = (char *)malloc(200*sizeof(char));

  strcpy(qstr,"select user_internal_id from user where user_name = '");
  strcat(qstr,username);
  strcat(qstr,"'");
  
  printf("Query is %s\n",qstr);

  if (mysql_query(conn,qstr)){
    fprintf(stderr,"%s\n",mysql_error(conn));
    exit(1);
  } 

  free(qstr);
  res = mysql_use_result(conn);

  if (res) {
    id    = -1;
    num_fields = mysql_num_fields(res);

    printf("Num %d\n",num_fields);

    while((row = mysql_fetch_row(res))!= NULL) {
      id = atoi(row[0]);
    }

    if (id == -1) {
      return NULL;
    }

    mysql_free_result(res);
    
    user = (User *)malloc(sizeof(User));
      
    user->id = id;
    strcpy(user->name,username);
    printf("User %d\n",id);
    return user;
  }
  return NULL;
}

User *add_user_by_username(MYSQL *conn, char *username) {
  printf("Adding user %s\n",username);
  MYSQL_RES *res;

  char *qstr;

  qstr = (char *)malloc(200*sizeof(char));
  
  strcpy(qstr,"insert into user values(NULL,'");
  strcat(qstr,username);
  strcat(qstr,"')");
  
  printf("Query is %s\n",qstr);
  
  if (mysql_query(conn,qstr)){
    fprintf(stderr,"%s\n",mysql_error(conn));
    exit(1);
  } 
  
  res = mysql_use_result(conn);
  
  mysql_free_result(res);
  free(qstr);
  return NULL;
}
int get_labgroup_by_labgroup_name(MYSQL *conn,char *labgroup_name) {
  MYSQL_RES *res;
  MYSQL_ROW row;
  
  char *qstr;

  int id;
  int num_fields;

  qstr = (char *)malloc(200*sizeof(char));

  strcpy(qstr,"select labgroup_internal_id from labgroup where labgroup_name = '");
  strcat(qstr,labgroup_name);
  strcat(qstr,"'");
  
  printf("Query is %s\n",qstr);

  if (mysql_query(conn,qstr)){
    fprintf(stderr,"%s\n",mysql_error(conn));
    exit(1);
  } 

  free(qstr);
  res = mysql_use_result(conn);

  if (res) {
    id    = -1;
    num_fields = mysql_num_fields(res);

    printf("Num %d\n",num_fields);

    while((row = mysql_fetch_row(res))!= NULL) {
      id = atoi(row[0]);
    }

    mysql_free_result(res);
   
    return id;
  }
  return -1;
}

int add_labgroup_by_labgroup_name(MYSQL *conn, char *labgroup_name) {
  printf("Adding group %s\n",labgroup_name);
  MYSQL_RES *res;

  char *qstr;

  qstr = (char *)malloc(200*sizeof(char));
  
  strcpy(qstr,"insert into labgroup values(NULL,'");
  strcat(qstr,labgroup_name);
  strcat(qstr,"')");
  
  printf("Query is %s\n",qstr);
  
  if (mysql_query(conn,qstr)){
    fprintf(stderr,"%s\n",mysql_error(conn));
    exit(1);
  } 
  
  res = mysql_use_result(conn);
  
  mysql_free_result(res);
  free(qstr);

  return get_labgroup_by_labgroup_name(conn,labgroup_name);
}

char * read_line(FILE *file) {

  char *str = NULL;
  char  c;
  int   n = 0;

  while ((c = getc(file)) != EOF && c != '\n') {

    if (str == NULL) {

      str = (char *)malloc(sizeof(char)*(2));
      n = 0;
      str[n] = c;
      str[n+1]   = '\0';

    } else {

      str = (char *)realloc(str,sizeof(char)*(strlen(str)+2));

      str[n] = c;
      str[n+1]   = '\0';

    }

    n++;

  }

  return str;
}

char * next_field(char *str, int *pos) {

  char *outstr = NULL;
  int   n      = 0;
  int   i      = *pos;

  while (i < strlen(str) && str[i]  != ' ') {
    if (outstr == NULL) {
      n = 0;
      outstr = (char *)malloc(sizeof(char)*(2));

      if (outstr == NULL) {
         printf("Can't allocate memory for outstr\n");
         exit(0);
      }
      outstr[n] = str[i];
      n++;
      outstr[n] = '\0';

    } else {

      outstr = (char *)realloc(outstr,sizeof(char)*(strlen(outstr)+2));
      outstr[n] = str[i];
      n++;
      outstr[n] = '\0';
    }
    i++;
  }

  i++;

  *pos = i;

  return outstr;
}
char **read_words(int verbose,char *str) {

  char **words = NULL;
  char  *word  = NULL;

  int    count = 0;
  int    pos   = 0;

  if (verbose == 1) {
    printf("String %s\n",str);
  }

  words = (char **)malloc(sizeof(char *));

  while ((word = next_field(str,&pos)) != NULL) {
    if (verbose == 1) {
      printf("Field %s\n",word);
    }

    count++;

    words = (char **)realloc(words,sizeof(char *)*count);

    words[count-1] = word;

  }
  words = (char **)realloc(words,sizeof(char *)*(count+1));
  words[count] = NULL;
  return words;
}

