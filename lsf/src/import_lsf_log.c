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
#include <argp.h>

/* /n/RC_Team/lsf_logs_sorted/acct contains old logs */
/* /lsf/work/lsf-odyssey/logdir/lsb.acct is the current one */

/* Argument parsing code */

static error_t parse_opt(int key, char *arg, struct argp_state *state);

static        char doc[]       = "\nImports LSF log files (lsb.acct.*) to a mysql database\n";
static        char args_doc[]  = "";

static struct argp_option options[] = {
  {"test",    't',  0,     0,       "Parse file but don't save to mysql"},
  {"infile",  'f',  "FILE",0,       "The LSF lsb.acct.n file to parse"},
  {"force",   'F',  0,     0,       "Overwrite any existing records"},
  {"check",   'c',  0,     0,       "Check whether each record exists before saving"},
  {"print",   'p',  0,     0,       "Print the mysql insert statements"},
  { 0 }
};

struct arguments {
  char *args[2];
  int   test;
  int   force;
  int   check;
  int   print;
  char *infile;
};

static struct argp argp        = {options, parse_opt, args_doc, doc};

static error_t parse_opt(int key, char *arg, struct argp_state *state) {
  struct arguments *arguments = state->input;
  
  switch (key)  {
    
  case 't':
    arguments->test = 1;
    break;
  case 'F':
    arguments->force = 1;
    break;
  case 'f':
    arguments->infile = arg;
    break;
  case 'c':
    arguments->check = 1;
    break;
  case 'p':
    arguments->print = 1;
    break;
    
  case ARGP_KEY_ARG:
    if (state->arg_num >= 5) {
      argp_usage(state);
    }
    arguments->args[state->arg_num] = arg;
    break;
    
  case ARGP_KEY_END:
    if (state->arg_num < 0) {
      argp_usage(state);
      break;
      
    default: 
      return ARGP_ERR_UNKNOWN;
    }
  }
  return 0;
}


/* Record parsing code */

int  event_time_exists       (MYSQL *conn, char *starttime,char *endtime);
int  finish_job_exists       (MYSQL *conn, struct jobFinishLog *finishJob);
int  delete_job(MYSQL *conn, struct jobFinishLog *finishJob);
void check_whether_finish_jobs_exist(MYSQL *conn,FILE *fp);

int main(int argc, char **argv){

  struct     arguments arguments;

  arguments.check = 0;
  arguments.test  = 0;
  arguments.force = 0;
  arguments.infile = "-";

  argp_parse(&argp,argc,argv,0,0,&arguments);
  
  printf ("ARG1 = %s\nARG2 = %s\ninfile = %s\n"
	  "check = %s\nforce = %s\ntest = %s\n",
	  arguments.args[0], arguments.args[1],
	  arguments.infile,
	  arguments.check? "yes" : "no,",
	  arguments.force? "yes" : "no",
	  arguments.test?  "yes" : "no");

  FILE      *lsf_fp;
  MYSQL     *conn;

  struct eventRec     *record;
  struct jobFinishLog *finishJob;

  int qcount = 0;

  lsf_fp = fopen(arguments.infile, "r");

  if (lsf_fp == NULL) {
    perror(arguments.infile);
    exit(-1);
  }
  
  conn =  Mysql_Connect();

  if (!arguments.force) {
    check_whether_finish_jobs_exist(conn,lsf_fp);
  }

  int lineNum;

  char *qstr              =  (char *)malloc(100000*sizeof(char));
  
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
      //printf("Job id is %d\n",finishJob->jobId);
      char *name = finishJob->userName;
      User *user = find_user(name);

      if (!user) {
	printf("Adding new user %s\n",name);
	int id  = User_Mysql_Update(conn,name);
	user    = User_Create(name,id);
	add_user(user,"name");
      }

      strcpy(qstr,"insert into finish_job values(NULL");
      
      Mytime *subtime          = time_to_unixtime_value(finishJob->submitTime);
      Mytime *starttime        = time_to_unixtime_value(finishJob->startTime);
      Mytime *endtime          = time_to_unixtime_value(finishJob->endTime);
      Mytime *lastResizeTime   = time_to_unixtime_value(finishJob->lastResizeTime);

      //char *askedHostsString = join_string(finishJob->askedHosts,finishJob->numAskedHosts,",");
      //char *execHostsString  = join_string(finishJob->execHosts,finishJob->numExHosts,",");

      struct lsfRusage lsfr = finishJob->lsfRusage;

      add_query_int_value           (qstr,finishJob->jobId);
      add_query_int_value           (qstr,finishJob->userId);
      add_query_int_value           (qstr,user->id);
      add_query_int_value           (qstr,finishJob->options );
      add_query_int_value           (qstr,finishJob->numProcessors);
      add_query_int_value           (qstr,finishJob->jStatus);
      add_query_string_noquote_value(qstr,subtime->mysql_str);
      add_query_string_noquote_value(qstr,starttime->mysql_str);
      add_query_string_noquote_value(qstr,endtime->mysql_str);
      
      add_query_int_value           (qstr,subtime->year);
      add_query_int_value           (qstr,subtime->month);
      add_query_int_value           (qstr,subtime->mday);
      add_query_int_value           (qstr,subtime->wday);
      add_query_int_value           (qstr,subtime->hour);
      add_query_int_value           (qstr,subtime->min);
      add_query_int_value           (qstr,subtime->sec);


      add_query_string_value        (qstr,finishJob->queue,conn);

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



      add_query_string_value        (qstr,finishJob->resReq,conn);
      add_query_string_value        (qstr,finishJob->fromHost,conn);
      add_query_string_value        (qstr,finishJob->cwd,conn);
      add_query_string_value        (qstr,finishJob->inFile,conn);
      add_query_string_value        (qstr,finishJob->outFile,conn);
      add_query_string_value        (qstr,finishJob->errFile,conn);
      add_query_string_value        (qstr,finishJob->inFileSpool,conn);
      add_query_string_value        (qstr,finishJob->commandSpool,conn);	
      add_query_string_value        (qstr,finishJob->jobFile,conn);		
      add_query_int_value           (qstr,finishJob->numAskedHosts);		
      add_query_int_value           (qstr,finishJob->hostFactor);
      add_query_string_value        (qstr,"",conn);
      add_query_int_value           (qstr,finishJob->numExHosts);		
      add_query_string_value        (qstr,"",conn);		
      add_query_float_value         (qstr,finishJob->cpuTime);
      add_query_string_value        (qstr,finishJob->jobName,conn);		
      
      add_query_string_value        (qstr,finishJob->dependCond,conn);
      add_query_string_value        (qstr,finishJob->timeEvent,conn);		
      add_query_string_value        (qstr,finishJob->preExecCmd,conn);		
      add_query_string_value        (qstr,finishJob->mailUser,conn);		
      add_query_string_value        (qstr,finishJob->projectName,conn);		
      add_query_int_value           (qstr,finishJob->exitStatus);		
      add_query_int_value           (qstr,finishJob->maxNumProcessors);		
      add_query_string_value        (qstr,finishJob->loginShell,conn);		
      add_query_int_value           (qstr,finishJob->idx);		
      add_query_int_value           (qstr,finishJob->maxRMem);		
      add_query_int_value           (qstr,finishJob->maxRSwap);		
      add_query_string_value        (qstr,finishJob->rsvId,conn);		
      add_query_string_value        (qstr,finishJob->sla,conn);		
      add_query_int_value           (qstr,finishJob->exceptMask);		
      
      add_query_string_value        (qstr,finishJob->additionalInfo,conn);		
      add_query_int_value           (qstr,finishJob->exitInfo);		
      add_query_int_value           (qstr,finishJob->warningTimePeriod);		
      add_query_string_value        (qstr,finishJob->warningAction,conn);		
      add_query_string_value        (qstr,finishJob->chargedSAAP,conn);		
      add_query_string_value        (qstr,finishJob->licenseProject,conn);		
      add_query_string_value        (qstr,finishJob->app,conn);		
      add_query_string_value        (qstr,finishJob->postExecCmd,conn);		
      add_query_int_value           (qstr,finishJob->runtimeEstimation);		
      add_query_string_value        (qstr,finishJob->jgroup,conn);		
      add_query_int_value           (qstr,finishJob->options2);		
      add_query_string_value        (qstr,finishJob->requeueEValues,conn);		
      add_query_string_value        (qstr,finishJob->notifyCmd,conn);		
      add_query_string_noquote_value(qstr,lastResizeTime->mysql_str);
      add_query_string_value        (qstr,finishJob->jobDescription,conn);
      add_query_string_value        (qstr,finishJob->command,conn);
      
      strcat(qstr,")");
      qcount++; 

      if (arguments.print) {
	printf("Query string %s\n",qstr);
      }
      if (qcount%1000 == 0) {
        printf("Queries loaded = %d\n",qcount);
      }
      
      int save = 1;

      if (arguments.test) {
	save = 0;
      }

      if (arguments.check) {
	int count = finish_job_exists(conn,finishJob);

	if (count > 0)  {
	  if (arguments.force) {
	    printf("Job %d %s exists - deleting\n",finishJob->jobId,finishJob->queue);
	    delete_job(conn,finishJob);
	  } else {
	    printf("Job %d %s exists - not storing\n",finishJob->jobId,finishJob->queue);
	    save = 0;
	  }
	}
      }


      if (save  && mysql_query(conn,qstr)){
	fprintf(stderr,"%s\n",mysql_error(conn));
	exit(1);
      } 

      free(subtime);
      free(starttime);
      free(endtime);
      free(lastResizeTime);
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

  char       jobstr[100];
  char       userstr[100];

  char       utime[100];
  char       stime[100];

  sprintf(jobstr, "%d",finishJob->jobId);
  sprintf(userstr,"%d",finishJob->userId);
  sprintf(utime,  "%f",finishJob->lsfRusage.ru_utime);
  sprintf(stime,  "%f",finishJob->lsfRusage.ru_stime);

  strcpy(qstr,"select job_id,user_id,ru_utime,ru_stime from finish_job where ");

  strcat(qstr,"job_id = ");
  strcat(qstr,jobstr);

  strcat(qstr," and user_id = ");
  strcat(qstr,userstr);

  strcat(qstr," and ru_utime = ");
  strcat(qstr,utime);

  strcat(qstr," and ru_stime = ");
  strcat(qstr,stime);

  //printf("Checking %s\n",qstr);

  if (mysql_query(conn,qstr)){
    fprintf(stderr,"%s\n",mysql_error(conn));
    exit(1);
  } 
  
  free(qstr);

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

int delete_job(MYSQL *conn, struct jobFinishLog *finishJob) {
  MYSQL_RES *res;
  MYSQL_ROW  row;

  char      *qstr    = (char *)malloc(1000 * sizeof(char));

  char       jobstr[100];
  char       userstr[100];

  char       utime[100];
  char       stime[100];

  sprintf(jobstr, "%d",finishJob->jobId);
  sprintf(userstr,"%d",finishJob->userId);
  sprintf(utime,  "%f",finishJob->lsfRusage.ru_utime);
  sprintf(stime,  "%f",finishJob->lsfRusage.ru_stime);

  strcpy(qstr,"delete from finish_job where ");

  strcat(qstr,"job_id = ");
  strcat(qstr,jobstr);

  strcat(qstr," and user_id = ");
  strcat(qstr,userstr);

  strcat(qstr," and ru_utime = ");
  strcat(qstr,utime);

  strcat(qstr," and ru_stime = ");
  strcat(qstr,stime);

  printf("Deleting %s\n",qstr);

  if (mysql_query(conn,qstr)){
    fprintf(stderr,"%s\n",mysql_error(conn));
    exit(1);
  } 
  
  free(qstr);

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
