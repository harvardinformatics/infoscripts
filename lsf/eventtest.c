#include <stdio.h>
#include <time.h>
#include <lsf/lsf.h>
#include <lsf/lsbatch.h>
#include <stdlib.h> 
#include <string.h>

char *join_string(char **str_arr,int num_str,char *join);

int main(int argc, char *argv[]) {

/* The current event file is /lsf/work/lsf-odyssey/logdir/lsb.acct"
 * 
 * John Brunelle has all previous (mostly) event files in /n/RC_Team/lsf_logs.sorted/acct
 */
  char *eventFile = argv[1];

    FILE *fp;

    struct eventRec *record;

    int  lineNum = 0;

    if (argc != 2) {
        printf("Usage: %s jobname\n", argv[0]);
        exit(-1);
    }

    if (lsb_init(argv[0]) < 0) {
        lsb_perror("lsb_init");
        exit(-1);
    }

    fp = fopen(eventFile, "r");
    if (fp == NULL) {
        perror(eventFile);
        exit(-1);
    }

    for (;;) {

        record = lsb_geteventrec(fp, &lineNum);

        if (record == NULL) {
            if (lsberrno == LSBE_EOF)
                exit(0);
            lsb_perror("lsb_geteventrec");
            exit(-1);
        }


	if (record->type == EVENT_JOB_FINISH) {
	  
            finishJob = &(record->eventLog.jobFinishLog);
	    
	    int    jobId         = finishJob->jobId;
	    int    userId        = finishJob->userId;
	    char  *userName      = finishJob->userName;
	    int    options       = finishJob->options;
	    int    numProcessors = finishJob->numProcessors;
	    int    jStatus       = finishJob->jStatus;
	    time_t submitTime    = finishJob->submitTime;
	    time_t startTime     = finishJob->startTime;
	    time_t endTime       = finishJob->endTime;
	    char  *queue         = finishJob->queue;

	    char  *subtime       = ctime(&submitTime);
	    char  *starttime     = ctime(&startTime);
	    char  *endtime       = ctime(&endTime);

	    subtime[24]   = '\0';
	    starttime[24] = '\0';
	    endtime[24]   = '\0';

	    printf("\"\\N\",\"%d\",\"%d\",\"%s\",\"%d\",\"%d\",\"%d\",\"%ld\",\"%ld\",\"%ld\",\"%s\",",
		   jobId,
		   userId,
		   userName,
		   options,
		   numProcessors,
		   jStatus,
		   submitTime,
		   startTime,
		   endTime,
		   queue);
	    
	    char *resReq       = finishJob->resReq;
	    char *fromHost     = finishJob->fromHost;
	    char *cwd          = finishJob->cwd;
	    char *inFile       = finishJob->inFile;
	    char *outFile      = finishJob->outFile;
	    char *errFile      = finishJob->errFile;
	    char *inFileSpool  = finishJob->inFileSpool;

	    printf("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",",
		   resReq,
		   fromHost,
		   cwd,
		   inFile,
		   outFile,
		   errFile,
		   inFileSpool);
	    
	    char  *commandSpool  = finishJob->commandSpool;
	    char  *jobFile       = finishJob->jobFile;
	    int    numAskedHosts = finishJob->numAskedHosts;
	    char **askedHosts    = finishJob->askedHosts;
	    float  hostFactor    = finishJob->hostFactor;
	    int    numExHosts    = finishJob->numExHosts;
	    char **execHosts     = finishJob->execHosts;
	    float  cpuTime       = finishJob->cpuTime;
	    char  *jobName       = finishJob->jobName;
	    char  *command       = finishJob->command;

	    char *askedHostsString = join_string(askedHosts,numaskedHosts,",");
	    char *execHostsString  = join_string(execHosts,numExHosts,",");


	    printf("\"%s\",\"%s\",\"%d\",\"%s\",\"%f\",\"%d\",\"%s\",\"%f\",\"%s\",",commandSpool,jobFile,numAskedHosts,askedHostsString,hostFactor,numExHosts,execHostsString,cpuTime,jobName);

	    /*struct lsfRuage *lsfRusage = finishJob->lsfRusage;*/
	    char *dependCond       = finishJob->dependCond;
	    char *timeEvent        = finishJob->timeEvent;
	    char *preExecCmd       = finishJob->preExecCmd;
	    char *mailUser         = finishJob->mailUser;
	    char *projectName      = finishJob->projectName;
	    int   exitStatus       = finishJob->exitStatus;
	    int   maxNumProcessors = finishJob->maxNumProcessors;

	    printf("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%d\",\"%d\",",dependCond,timeEvent,preExecCmd,mailUser,projectName,exitStatus,maxNumProcessors);

	    char *loginShell      = finishJob->loginShell;
	    int   idx             = finishJob->idx;
	    int   maxRMem         = finishJob->maxRMem;
	    int   maxRSwap        = finishJob->maxRSwap;
	    char *rsvId           = finishJob->rsvId;
	    char *sla             = finishJob->sla;
	    int   exceptMask      = finishJob->exceptMask;
	    char *additionalInfo  = finishJob->additionalInfo;

	    printf("\"%s\",\"%d\",\"%d\",\"%d\",\"%s\",\"%s\",\"%d\",\"%s\",",loginShell,idx,maxRMem,maxRSwap,rsvId,sla,exceptMask,additionalInfo);

	    int    exitInfo          = finishJob->exitInfo;
	    int    warningTimePeriod = finishJob->warningTimePeriod;
	    char  *warningAction     = finishJob->warningAction;
	    char  *chargedSAAP       = finishJob->chargedSAAP;
	    char  *licenseProject    = finishJob->licenseProject;
	    char  *app               = finishJob->app;
	    char  *postExecCmd       = finishJob->postExecCmd;
	    int    runtimeEstimation = finishJob->runtimeEstimation;
	    char  *jgroup            = finishJob->jgroup;
	    int    options2          = finishJob->options2;
	    char  *requeueEValues    = finishJob->requeueEValues;
	    char  *notifyCmd         = finishJob->notifyCmd;
	    time_t lastResizeTime    = finishJob->lastResizeTime;
	    char   *jobDescription   = finishJob->jobDescription;
	    /*	    struct submit_ext *submitExt = finishJob->submitExt;*/

	    char *tmpstr = ctime(&lastResizeTime);

	    tmpstr[24] = '\0';

	    printf("\"%d\",\"%d\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%d\",\"%s\",\"%d\",\"%s\",\"%s\",\"%ld\",\"%s\",\"%s;\n",
		   exitInfo,
		   warningTimePeriod,
		   warningAction,
		   chargedSAAP,
		   licenseProject,
		   app,
		   postExecCmd,
		   runtimeEstimation,
		   jgroup,
		   options2,
		   requeueEValues,
		   notifyCmd,
		   lastResizeTime,
		   jobDescription,
		   command);

	}
	
    }
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
