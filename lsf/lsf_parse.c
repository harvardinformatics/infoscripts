/* Simple C program that connects to MySQL Database server*/

#include <mysql.h>
#include <stdio.h>
#include <string.h>
#include <lsf/lsf.h>
#include <lsf/lsbatch.h>
#include <time.h>
#include <stdlib.h>

#define QUERY_INT    1;
#define QUERY_FLOAT  2;
#define QUERY_STRING 3;

typedef struct _User {
  int id;             /* This is the internal id in the mysql db */
  char *name;         /* This is the key string */        
} User;

char **read_words(int verbose,char *str);
char  *read_line(FILE *file);
char  *next_field(char *str, int *pos);
User  *get_user_by_username(MYSQL *conn,char *username);
User  *add_user_by_username(MYSQL *conn,char *username);
int    get_labgroup_by_labgroup_name(MYSQL *conn,char *labgroup_name);
int    add_labgroup_by_labgroup_name(MYSQL *conn,char *labgroup_name);
void   update_user_and_labgroup(MYSQL *conn, int user, int *group);
void add_query_int_value(char *qstr,int value);
void add_query_float_value(char *qstr,float value);
void add_query_string_value(char *qstr,char *value);
char *join_string(char **str_arr,int num_str,char *join);

int main(int argc, char *argv[]){

  FILE      *user_fp;
  FILE      *lsf_fp;
  MYSQL     *conn;
  char      *server   = "localhost";
  char      *user     = "root";
  char      *password = "98lsf76";
  char      *database = "lsf";
  char      *userfile;
  char      *lsffile;

  struct eventRec     *record;
  struct jobFinishLog *finishJob;

  if (argc != 3) {
    printf("Usage: %s <userfile> <lsf.acct file>\n", argv[0]);
    exit(-1);
  }
    
  userfile = argv[1];
  lsffile  = argv[2];

  user_fp = fopen(userfile, "r");
  lsf_fp  = fopen(lsffile, "r");

  if (user_fp == NULL) {
    perror(userfile);
    exit(-1);
  }
  
  if (lsf_fp == NULL) {
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

  int  group;
  int *groups;
  int  i;

  line = NULL;

  while ((line = read_line(user_fp)) && line != NULL) {
    printf("Lin %s\n",line);
    words    = read_words(1,line);
    username = words[0];
    printf("User %s\n",username);
    userobj  = get_user_by_username(conn,username);
    
    if (userobj == NULL) {
      printf("Adding User %s %d\n",username,userobj->id);
      
      userobj = add_user_by_username(conn,username);
      
    }
    
    i = 2;

    groups     = (int *)malloc(100*sizeof(int));
    
    int gcount = 0;
    
    while (words[i] != NULL) {
      group = get_labgroup_by_labgroup_name(conn,words[i]);

      if (group == -1) {
	group = add_labgroup_by_labgroup_name(conn,words[i]);
	printf("Adding labgroup %s %d\n",words[i],group);
      }

      if (gcount > 100) {
	groups = (int *)realloc(groups,sizeof(groups)*(gcount+100));
      }

      groups[gcount] = group;

      gcount++;
      i++;
      
    }

    i = 0;

    while (words[i] != NULL) {
      free(words[i]);
      i++;
    }

    groups[gcount] = -1;

    update_user_and_labgroup(conn,userobj->id,groups);


    free(line);
    free(username);
    free(groups);
    free(words);
    free(userobj->name);
    free(userobj);
  }
  
  printf("Loaded/updated users and groups\n");

  int lineNum;

  for (;;) {

    record = lsb_geteventrec(lsf_fp, &lineNum);
    
    if (record == NULL) {
      if (lsberrno == LSBE_EOF)
	exit(0);
      lsb_perror("lsb_geteventrec");
      exit(-1);
    }


    char *qstr = NULL;

    qstr = (char *)malloc(1000*sizeof(char));

    if (record->type == EVENT_JOB_FINISH) {
	  
      finishJob = &(record->eventLog.jobFinishLog);

      strcpy(qstr,"insert into finish_job values(NULL,");
      
      char  *subtime        = ctime(&finishJob->submitTime);
      char  *starttime      = ctime(&finishJob->startTime);
      char  *endtime        = ctime(&finishJob->endTime);
      char  *lastResizeTime = ctime(&finishJob->lastResizeTime);

      subtime[24]        = '\0';
      starttime[24]      = '\0';
      endtime[24]        = '\0';
      lastResizeTime[24] = '\0';

      char *askedHostsString = join_string(finishJob->askedHosts,finishJob->numAskedHosts,",");
      char *execHostsString  = join_string(finishJob->execHosts,finishJob->numExHosts,",");

      /*struct lsfRusage *lsfRusage = finishJob->lsfRusage;*/      

      add_query_int_value(qstr,finishJob->jobId);
      add_query_int_value(qstr,finishJob->userId);
      add_query_string_value(qstr,finishJob->userName);
      add_query_int_value(qstr,finishJob->options );
      add_query_int_value(qstr,finishJob->numProcessors);
      add_query_int_value(qstr,finishJob->jStatus);
      add_query_string_value(qstr,subtime);
      add_query_string_value(qstr,starttime);
      add_query_string_value(qstr,endtime);
      add_query_string_value(qstr,finishJob->queue);
      add_query_string_value(qstr,finishJob->resReq);
      add_query_string_value(qstr,finishJob->fromHost);
      add_query_string_value(qstr,finishJob->cwd);
      add_query_string_value(qstr,finishJob->inFile);
      add_query_string_value(qstr,finishJob->outFile);
      add_query_string_value(qstr,finishJob->errFile);
      add_query_string_value(qstr,finishJob->inFileSpool);
      add_query_string_value(qstr,finishJob->commandSpool);	
      add_query_string_value(qstr,finishJob->jobFile);		
      add_query_int_value(qstr,finishJob->numAskedHosts);		
      add_query_string_value(qstr,askedHostsString);
      add_query_int_value(qstr,finishJob->numExHosts);		
      add_query_string_value(qstr,execHostsString);		
      add_query_float_value(qstr,finishJob->cpuTime);
      add_query_string_value(qstr,finishJob->jobName);		

      add_query_string_value(qstr,finishJob->dependCond);		    
      add_query_string_value(qstr,finishJob->timeEvent);		
      add_query_string_value(qstr,finishJob->preExecCmd);		
      add_query_string_value(qstr,finishJob->mailUser);		
      add_query_string_value(qstr,finishJob->projectName);		
      add_query_int_value(qstr,finishJob->exitStatus);		
      add_query_int_value(qstr,finishJob->maxNumProcessors);		
      add_query_string_value(qstr,finishJob->loginShell);		
      add_query_int_value(qstr,finishJob->idx);		
      add_query_int_value(qstr,finishJob->maxRMem);		
      add_query_int_value(qstr,finishJob->maxRSwap);		
      add_query_string_value(qstr,finishJob->rsvId);		
      add_query_string_value(qstr,finishJob->sla);		
      add_query_int_value(qstr,finishJob->exceptMask);		

      add_query_string_value(qstr,finishJob->additionalInfo);		
      add_query_int_value(qstr,finishJob->exitInfo);		
      add_query_int_value(qstr,finishJob->warningTimePeriod);		
      add_query_string_value(qstr,finishJob->warningAction);		
      add_query_string_value(qstr,finishJob->chargedSAAP);		
      add_query_string_value(qstr,finishJob->licenseProject);		
      add_query_string_value(qstr,finishJob->app);		
      add_query_string_value(qstr,finishJob->postExecCmd);		
      add_query_int_value(qstr,finishJob->runtimeEstimation);		
      add_query_string_value(qstr,finishJob->jgroup);		
      add_query_int_value(qstr,finishJob->options2);		
      add_query_string_value(qstr,finishJob->requeueEValues);		
      add_query_string_value(qstr,finishJob->notifyCmd);		
      add_query_string_value(qstr,lastResizeTime);
      add_query_string_value(qstr,finishJob->jobDescription);
      add_query_string_value(qstr,finishJob->command);
     
      qstr = (char *)realloc(qstr,(strlen(qstr)+2)*sizeof(char));
      
      strcat(qstr,")");

      printf("Query string %s\n",qstr);
    }
  }
  mysql_close(conn); 
  
  return 1;
}

void add_query_int_value(char *qstr,int value) {

  char valstr[100];
  
  sprintf(valstr,"%d",value);
  qstr = realloc(qstr,(strlen(qstr)+strlen(valstr)+2)*sizeof(char));
  strcat(qstr,",");
  strcat(qstr,valstr);
}
void add_query_float_value(char *qstr,float value) {

  char valstr[100];
  
  sprintf(valstr,"%f",value);
  qstr = realloc(qstr,(strlen(qstr)+strlen(valstr)+2)*sizeof(char));
  strcat(qstr,",");
  strcat(qstr,valstr);

}
void add_query_string_value(char *qstr,char *value) {
  
  qstr = realloc(qstr,(strlen(qstr)+strlen(value)+2+2)*sizeof(char));
  strcat(qstr,",'");
  strcat(qstr,value);
  strcat(qstr,"'");

}

void update_user_and_labgroup(MYSQL *conn, int user, int *group) {
  char str[100];
  sprintf(str,"%d",user);
  char *qstr;
  
  qstr = (char *)malloc(200*sizeof(char));

  strcpy(qstr,"delete from user_group where user_internal_id = ");
  strcat(qstr,str);

  //printf("Query is %s\n",qstr);

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

  //printf("Query is %s\n",qstr);

  if (mysql_query(conn,qstr)){
    fprintf(stderr,"%s\n",mysql_error(conn));
    exit(1);
  } 
  free(qstr);
}

User *get_user_by_username(MYSQL *conn,char *username) {
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
  
  printf("Query is %s\n",qstr);

  if (mysql_query(conn,qstr)){
    fprintf(stderr,"%s\n",mysql_error(conn));
    exit(1);
  } 
  
  free(qstr);
  res = mysql_use_result(conn);

  if (res != NULL) {
    id    = -1;
    num_fields = mysql_num_fields(res);
    
    printf("Got results %d\n",mysql_field_count(conn));
    while ((row = mysql_fetch_row(res))) {
      printf("Got results %d\n",mysql_field_count(conn));
      if (mysql_field_count(conn) > 0) {
	id = atoi(row[0]);
      }
    }

    if (id == -1) {
      return NULL;
    }

    mysql_free_result(res);
    
    user = (User *)malloc(sizeof(User));
    
    user->name = (char *)malloc((strlen(username)+1)*sizeof(char));
    user->id = id;
    strcpy(user->name,username);

    return user;
  }
  return NULL;
}

User *add_user_by_username(MYSQL *conn, char *username) {
  MYSQL_RES *res;
  char      *qstr;

  qstr = (char *)malloc(200*sizeof(char));
  
  strcpy(qstr,"insert into user values(NULL,'");
  strcat(qstr,username);
  strcat(qstr,"')");
  
  //printf("Query is %s\n",qstr);
  
  if (mysql_query(conn,qstr)){
    fprintf(stderr,"%s\n",mysql_error(conn));
    exit(1);
  } 
  
  res = mysql_use_result(conn);
  
  mysql_free_result(res);
  free(qstr);
  return get_user_by_username(conn,username);
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
  
  //printf("Query is %s\n",qstr);

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
   
    return id;
  }
  return -1;
}

int add_labgroup_by_labgroup_name(MYSQL *conn, char *labgroup_name) {
  MYSQL_RES *res;

  char *qstr;

  qstr = (char *)malloc(200*sizeof(char));
  
  strcpy(qstr,"insert into labgroup values(NULL,'");
  strcat(qstr,labgroup_name);
  strcat(qstr,"')");
  
  //printf("Query is %s\n",qstr);
  
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
      printf("Outstr :%s:\n",outstr);
    } else {

      outstr = (char *)realloc(outstr,sizeof(char)*(strlen(outstr)+2));
      outstr[n] = str[i];
      n++;
      outstr[n] = '\0';
      printf("Outstr :%s:\n",outstr);
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

  words = (char **)malloc(100*sizeof(char *));

  while ((word = next_field(str,&pos)) != NULL) {
    if (verbose == 1) {
      printf("Field %s\n",word);
    }

    count++;
    printf("Count %d\n",count);
    //words = (char **)realloc(words,sizeof(char *)*count);
    printf("Count2 %d\n",count);
    words[count-1] = word;

  }
  //words = (char **)realloc(words,sizeof(char *)*(count+1));
  words[count] = NULL;
  return words;
}

char *join_string(char **str_arr,int num_str,char *join) {

  char *outstr = (char *)malloc(100 * sizeof(char));

  outstr[0] = '\0';

  int i   = 0;
  int len = 100;

  while (i < num_str) {
    if (i == 0) {
      strcpy(outstr,*str_arr);
    } else {
      
      if (strlen(outstr)+strlen(*str_arr) +1 > len) {
	outstr = (char *)realloc(outstr,strlen(outstr)+strlen(*str_arr) + 100);
      }


      strcat(outstr,join);
      strcat(outstr,*str_arr);
      
    }
    str_arr++;
    i++;
  }
  return outstr;
}
