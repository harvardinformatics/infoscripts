/* Parses an lsb.acct file and stores to a db */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <mysql.h>
#include <lsf/lsf.h>
#include <lsf/lsbatch.h>
#include "uthash.h"
#include "utils.h"
#include "labgroup.h"
#include "mysql.h"

/* /n/RC_Team/lsf_logs_sorted/acct contains old logs */
/* /lsf/work/lsf-odyssey/logdir/lsb.acct is the current one */

int  event_time_exists       (MYSQL *conn, char *starttime,char *endtime);
int  finish_job_exists       (MYSQL *conn, struct jobFinishLog *finishJob);
void check_whether_finish_jobs_exist(MYSQL *conn,FILE *fp);

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

  check_whether_finish_jobs_exist(conn,lsf_fp);

  int lineNum;

  char *qstr              =  (char *)malloc(10000*sizeof(char));
  
  for (;;) {

    record = lsb_geteventrec(lsf_fp, &lineNum);
    
    if (record == NULL) {
      if (lsberrno == LSBE_EOF)
	exit(0);
      lsb_perror("lsb_geteventrec");
      exit(-1);
    }

    if (record->type == EVENT_JOB_FINISH) {
	  
      finishJob = &(record->eventLog.jobFinishLog);

      char *name = finishJob->userName;
      User *user = find_user(name);

      if (!user) {
	printf("Adding new user %s\n",name);
	int id  = User_Mysql_Update(conn,name);
	user    = User_Create(name,id);
	add_user(user,"name");
      }

      strcpy(qstr,"insert into finish_job values(NULL");
      
      char *subtime          = time_to_unixtime_value(finishJob->submitTime);
      char *starttime        = time_to_unixtime_value(finishJob->startTime);
      char *endtime          = time_to_unixtime_value(finishJob->endTime);
      char *lastResizeTime   = time_to_unixtime_value(finishJob->lastResizeTime);

      char *askedHostsString = join_string(finishJob->askedHosts,finishJob->numAskedHosts,",");
      char *execHostsString  = join_string(finishJob->execHosts,finishJob->numExHosts,",");

      char *esc_command      = Mysql_Escape_String(conn,finishJob->command);
      char *esc_resreq       = Mysql_Escape_String(conn,finishJob->resReq);
      char *esc_depcond      = Mysql_Escape_String(conn,finishJob->dependCond);


      struct lsfRusage lsfr = finishJob->lsfRusage;

      add_query_int_value           (qstr,finishJob->jobId);
      add_query_int_value           (qstr,finishJob->userId);
      add_query_int_value           (qstr,user->id);
      add_query_int_value           (qstr,finishJob->options );
      add_query_int_value           (qstr,finishJob->numProcessors);
      add_query_int_value           (qstr,finishJob->jStatus);
      add_query_string_noquote_value(qstr,subtime);
      add_query_string_noquote_value(qstr,starttime);
      add_query_string_noquote_value(qstr,endtime);

      add_query_string_value        (qstr,finishJob->queue);
      add_query_float_value(qstr,lsfr.ru_utime);  /* User time used */
      add_query_float_value(qstr,lsfr.ru_stime);  /* System time used */
      add_query_float_value(qstr,lsfr.ru_maxrss); /* Max rss */
      add_query_float_value(qstr,lsfr.ru_ixrss);  /* Integral shared text size */
      add_query_float_value(qstr,lsfr.ru_idrss);  /* Integral unshared data */
      add_query_float_value(qstr,lsfr.ru_isrss);  /* Integral unshared stack */
      add_query_float_value(qstr,lsfr.ru_minflt); /* Page reclaims */
      add_query_float_value(qstr,lsfr.ru_majflt); /* Page faults */
      add_query_float_value(qstr,lsfr.ru_nswap);  /* Swaps */
      add_query_float_value(qstr,lsfr.ru_inblock); /* Block inpu toperations */
      add_query_float_value(qstr,lsfr.ru_oublock); /* Block output operations */
      add_query_float_value(qstr,lsfr.ru_msgsnd); /* Messages sent */
      add_query_float_value(qstr,lsfr.ru_msgrcv); /* Messages received */
      add_query_float_value(qstr,lsfr.ru_nsignals); /* Signals received */
      add_query_float_value(qstr,lsfr.ru_nvcsw); /* voluntary context switches */
      add_query_float_value(qstr,lsfr.ru_nivcsw); /* involuntary context switches */



      add_query_string_value        (qstr,esc_resreq);
      add_query_string_value        (qstr,finishJob->fromHost);
      add_query_string_value        (qstr,finishJob->cwd);
      add_query_string_value        (qstr,finishJob->inFile);
      add_query_string_value        (qstr,finishJob->outFile);
      add_query_string_value        (qstr,finishJob->errFile);
      add_query_string_value        (qstr,finishJob->inFileSpool);
      add_query_string_value        (qstr,finishJob->commandSpool);	
      add_query_string_value        (qstr,finishJob->jobFile);		
      add_query_int_value           (qstr,finishJob->numAskedHosts);		
      add_query_int_value           (qstr,finishJob->hostFactor);
      add_query_string_value        (qstr,askedHostsString);
      add_query_int_value           (qstr,finishJob->numExHosts);		
      add_query_string_value        (qstr,execHostsString);		
      add_query_float_value         (qstr,finishJob->cpuTime);
      add_query_string_value        (qstr,finishJob->jobName);		
      
      add_query_string_value        (qstr,esc_depcond);		    
      add_query_string_value        (qstr,finishJob->timeEvent);		
      add_query_string_value        (qstr,finishJob->preExecCmd);		
      add_query_string_value        (qstr,finishJob->mailUser);		
      add_query_string_value        (qstr,finishJob->projectName);		
      add_query_int_value           (qstr,finishJob->exitStatus);		
      add_query_int_value           (qstr,finishJob->maxNumProcessors);		
      add_query_string_value        (qstr,finishJob->loginShell);		
      add_query_int_value           (qstr,finishJob->idx);		
      add_query_int_value           (qstr,finishJob->maxRMem);		
      add_query_int_value           (qstr,finishJob->maxRSwap);		
      add_query_string_value        (qstr,finishJob->rsvId);		
      add_query_string_value        (qstr,finishJob->sla);		
      add_query_int_value           (qstr,finishJob->exceptMask);		
      
      add_query_string_value        (qstr,finishJob->additionalInfo);		
      add_query_int_value           (qstr,finishJob->exitInfo);		
      add_query_int_value           (qstr,finishJob->warningTimePeriod);		
      add_query_string_value        (qstr,finishJob->warningAction);		
      add_query_string_value        (qstr,finishJob->chargedSAAP);		
      add_query_string_value        (qstr,finishJob->licenseProject);		
      add_query_string_value        (qstr,finishJob->app);		
      add_query_string_value        (qstr,finishJob->postExecCmd);		
      add_query_int_value           (qstr,finishJob->runtimeEstimation);		
      add_query_string_value        (qstr,finishJob->jgroup);		
      add_query_int_value           (qstr,finishJob->options2);		
      add_query_string_value        (qstr,finishJob->requeueEValues);		
      add_query_string_value        (qstr,finishJob->notifyCmd);		
      add_query_string_noquote_value(qstr,lastResizeTime);
      add_query_string_value        (qstr,finishJob->jobDescription);
      add_query_string_value        (qstr,esc_command);
      
      strcat(qstr,")");
      
     //printf("Query string %s\n",qstr);
	
      if (mysql_query(conn,qstr)){
	fprintf(stderr,"%s\n",mysql_error(conn));
	exit(1);
      } 

      free(subtime);
      free(starttime);
      free(endtime);
      free(lastResizeTime);
      free(askedHostsString);
      free(execHostsString);
      free(esc_command);
      free(esc_resreq);
      free(esc_depcond);
    }
  }
  mysql_close(conn); 
  
  return 1;
}

void check_whether_finish_jobs_exist(MYSQL *conn,FILE *fp) {
  struct eventRec     *record;
  struct jobFinishLog *finishJob;

  char c;
  int  lineNum;
  int  loaded = 0;

  /* Point to the start of the file  - read and check one record*/

  rewind(fp);

  record    = lsb_geteventrec(fp, &lineNum);
  finishJob = &(record->eventLog.jobFinishLog);

  if (finish_job_exists(conn,finishJob) == 1) {
    loaded = 1;
    printf("First event has been loaded - won't load file\n");
  }

  /* Now go to the end and back up one line */

  fseek(fp,0,SEEK_END);

  while ((c = getc(fp)) != '\n') {
    fseek(fp,-2,SEEK_CUR);
  }

  /* Read and check the last record */

  record    = lsb_geteventrec(fp, &lineNum);
  finishJob = &(record->eventLog.jobFinishLog);

  if (finish_job_exists(conn,finishJob) == 1) {
    loaded = 1;
    printf("Last event has been loaded - won't load file\n");
  }

  /* Put the file pointer back to the beginning */
  rewind(fp);

  if (loaded == 1) {
    exit(-1);
  }
}

int finish_job_exists(MYSQL *conn, struct jobFinishLog *finishJob) {
  MYSQL_RES *res;
  MYSQL_ROW  row;

  char      *qstr    = (char *)malloc(1000 * sizeof(char));
  char      *timestr = time_to_unixtime_value(finishJob->submitTime);  

  char       jobstr[100];
  char       userstr[100];

  sprintf(jobstr,"%d",finishJob->jobId);
  sprintf(userstr,"%d",finishJob->userId);

  strcpy(qstr,"select job_id,submit_time,user_id from finish_job where ");

  strcat(qstr,"job_id = ");
  strcat(qstr,jobstr);

  strcat(qstr," and user_id = ");
  strcat(qstr,userstr);

  strcat(qstr," and submit_time = ");
  strcat(qstr,timestr);

  if (mysql_query(conn,qstr)){
    fprintf(stderr,"%s\n",mysql_error(conn));
    exit(1);
  } 
  
  free(qstr);
  free(timestr);

  res = mysql_use_result(conn);

  int count = 0;

  if (res) {

    while((row = mysql_fetch_row(res))!= NULL) {
      count = atoi(row[0]);
    }

    mysql_free_result(res);

  }   
  return count;
}
