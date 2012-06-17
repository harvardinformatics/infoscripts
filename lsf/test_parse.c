/* Simple C program that connects to MySQL Database server*/

#include<mysql.h>
#include<stdio.h>
#include <stdlib.h>
#include <string.h>
#include <lsf/lsf.h>
#include <lsf/lsbatch.h>
#include "uthash.h"
#include <time.h>
#include "utils.h"
#include "labgroup.h"
#include "mysql.h"

/* /n/RC_Team/lsf_logs_sorted/acct contains old logs */
/* /lsf/work/lsf-odyssey/logdir/lsb.acct is the current one */



int    event_time_exists       (MYSQL *conn, char *starttime,char *endtime);
void   read_start_and_end_times(MYSQL *conn,FILE *fp,char *starttime,char *endtime);

int main(int argc, char *argv[]){

  FILE      *lsf_fp;
  MYSQL     *conn;
  char      *lsffile = argv[1];

  struct eventRec     *record;
  struct jobFinishLog *finishJob;

  if (argc != 2) {
    printf("Usage: %s <lsb.acct file>\n", argv[0]);
    exit(-1);
  }
    
  lsf_fp = fopen(lsffile, "r");

  if (lsf_fp == NULL) {
    perror(lsffile);
    exit(-1);
  }
  
  conn =  Mysql_Connect();

  int lineNum;

  char  *subtime;
  char  *starttime;
  char  *endtime;
  char  *lastResizeTime;

  subtime        = (char *)malloc(40*sizeof(char));
  starttime      = (char *)malloc(40*sizeof(char));
  endtime        = (char *)malloc(40*sizeof(char));
  lastResizeTime = (char *)malloc(40*sizeof(char));

  char *start_submit_time = '\0';
  char *end_submit_time   = '\0';

  read_start_and_end_times(conn,lsf_fp,start_submit_time,end_submit_time);
  
  for (;;) {

    record = lsb_geteventrec(lsf_fp, &lineNum);
    
    if (record == NULL) {
      if (lsberrno == LSBE_EOF)
	exit(0);
      lsb_perror("lsb_geteventrec");
      exit(-1);
    }


    char *qstr = NULL;

    qstr = (char *)malloc(10000*sizeof(char));

    if (record->type == EVENT_JOB_FINISH) {
	  
      finishJob = &(record->eventLog.jobFinishLog);

      strcpy(qstr,"insert into finish_job values(NULL");
      

      strcpy(subtime,"from_unixtime(");
      strcpy(starttime,"from_unixtime(");
      strcpy(endtime,"from_unixtime(");
      strcpy(lastResizeTime,"from_unixtime(");

      char *tmp_sub = (char *)malloc(26*sizeof(char));;
      char *tmp_start = (char *)malloc(26*sizeof(char));;
      char *tmp_end = (char *)malloc(26*sizeof(char));;
      char *tmp_res = (char *)malloc(26*sizeof(char));;


      sprintf(tmp_sub,"%ld",finishJob->submitTime);
      sprintf(tmp_start,"%ld",finishJob->startTime);
      sprintf(tmp_end,"%ld",finishJob->endTime);
      sprintf(tmp_res,"%ld",finishJob->lastResizeTime);

      tmp_sub[24] = '\0';
      tmp_start[24] = '\0';
      tmp_end[24] = '\0';
      tmp_res[24] = '\0';

      strcat(subtime, tmp_sub);
      strcat(starttime, tmp_start);
      strcat(endtime,   tmp_end);
      strcat(lastResizeTime, tmp_res);

      strcat(subtime,")");
      strcat(starttime,")");
      strcat(endtime,")");
      strcat(lastResizeTime,")");


      char *askedHostsString = join_string(finishJob->askedHosts,finishJob->numAskedHosts,",");
      char *execHostsString  = join_string(finishJob->execHosts,finishJob->numExHosts,",");

      /*struct lsfRusage *lsfRusage = finishJob->lsfRusage;*/      

      User *user;
      char *name;

      name = finishJob->userName;
      user = find_user(name);

      if (!user) {
	printf("Adding new user %s\n",name);
	int id  = User_Mysql_Update(conn,name);
	user    = User_Create(name,id);
	add_user(user,"name");
      }
      char *esc_command;
      char *esc_resreq;
      char *esc_fromhost;

      esc_command  = (char *)malloc((strlen(finishJob->command)*2+1)*sizeof(char));
      esc_resreq   = (char *)malloc((strlen(finishJob->resReq)*2+1)*sizeof(char));      
      esc_fromhost = (char *)malloc((strlen(finishJob->fromHost)*2+1)*sizeof(char));      

      mysql_real_escape_string(conn,esc_command,finishJob->command,strlen(finishJob->command));
      mysql_real_escape_string(conn,esc_resreq,finishJob->resReq,strlen(finishJob->resReq));
      mysql_real_escape_string(conn,esc_fromhost,finishJob->fromHost,strlen(finishJob->fromHost));
      
      add_query_int_value(qstr,finishJob->jobId);
      add_query_int_value(qstr,finishJob->userId);
      add_query_int_value(qstr,user->id);
      add_query_int_value(qstr,finishJob->options );
      add_query_int_value(qstr,finishJob->numProcessors);
      add_query_int_value(qstr,finishJob->jStatus);
      add_query_string_noquote_value(qstr,subtime);
      add_query_string_noquote_value(qstr,starttime);
      add_query_string_noquote_value(qstr,endtime);
      add_query_string_value(qstr,finishJob->queue);
      add_query_string_value(qstr,esc_resreq);
      add_query_string_value(qstr,esc_fromhost);
      add_query_string_value(qstr,finishJob->cwd);
      add_query_string_value(qstr,finishJob->inFile);
      add_query_string_value(qstr,finishJob->outFile);
      add_query_string_value(qstr,finishJob->errFile);
      add_query_string_value(qstr,finishJob->inFileSpool);
      add_query_string_value(qstr,finishJob->commandSpool);	
      add_query_string_value(qstr,finishJob->jobFile);		
      add_query_int_value(qstr,finishJob->numAskedHosts);		
      add_query_int_value(qstr,finishJob->hostFactor);
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
      add_query_string_noquote_value(qstr,lastResizeTime);
      add_query_string_value(qstr,finishJob->jobDescription);
      
      add_query_string_value(qstr,esc_command);
      
      strcat(qstr,")");
      
      printf("Query string %s\n",qstr);
	
	if (mysql_query(conn,qstr)){
	  fprintf(stderr,"%s\n",mysql_error(conn));
	  exit(1);
	} 
      
      free(qstr);

    }
  }
  mysql_close(conn); 
  
  return 1;
}

  


int event_time_exists(MYSQL *conn, char *starttime,char *endtime) {
  MYSQL_RES *res;
  MYSQL_ROW  row;
  char      *qstr;
  int        num_fields;

  qstr = (char *)malloc(200*sizeof(char));
  
  strcpy(qstr,"select count(*) from finish_job where submit_time >= from_unixtime(");
  strcat(qstr,starttime);
  strcat(qstr,") and submit_time <= from_unixtime(");
  strcat(qstr,endtime);
  strcat(qstr,")");

  printf("Query is %s\n",qstr);
  
  if (mysql_query(conn,qstr)){
    fprintf(stderr,"%s\n",mysql_error(conn));
    exit(1);
  } 
  
  res = mysql_use_result(conn);

  free(qstr);

  int found = 0;
  
  if (res) {
    num_fields = mysql_num_fields(res);

    
    while((row = mysql_fetch_row(res))!= NULL) {
      found = atoi(row[0]);
    }

    mysql_free_result(res);

    
    printf("Found %d existing submit time for this entry %s %s\n",found,starttime,endtime);
  }


  return found;
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

void read_start_and_end_times(MYSQL *conn,FILE *fp,char *starttime,char *endtime) {
  int lineNum;

  struct eventRec     *record;
  struct jobFinishLog *finishJob;

  char tmpstart[24];
  char tmpend[24];

  rewind(fp);

  record    = lsb_geteventrec(fp, &lineNum);
  finishJob = &(record->eventLog.jobFinishLog);

  starttime   = (char *)malloc(26*sizeof(char));;

  sprintf(tmpstart,"%ld",finishJob->submitTime);

  strcpy(starttime,tmpstart);

  fseek(fp,0,SEEK_END);

  char c;

  while ((c = getc(fp)) != '\n') {
    //printf("Char %c\n",c);
    fseek(fp,-2,SEEK_CUR);
  }

  record    = lsb_geteventrec(fp, &lineNum);
  finishJob = &(record->eventLog.jobFinishLog);



  endtime   = (char *)malloc(26*sizeof(char));;

  sprintf(tmpend,"%ld",finishJob->submitTime);

  strcpy(endtime,tmpend);

  rewind(fp);

  int exists;
  exists = event_time_exists(conn,starttime,endtime);

  printf("Start end %s %s %d\n",starttime,endtime,exists);

  if (exists >= 1) {
    printf("Time range already loaded - delete range to load data\n");
    exit(-1);
  }
}

  
  
