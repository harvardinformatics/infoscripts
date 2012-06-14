#include <stdio.h>
#include <time.h>
#include <lsf/lsf.h>
#include <lsf/lsbatch.h>
#include <stdlib.h> 
#include <string.h>

int main(int argc, char *argv[]) {

/* The current event file is /lsf/work/lsf-odyssey/logdir/lsb.acct"
 * 
 * John Brunelle has all previous (mostly) event files in 
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

        /*printf("Record type %d time  %s\n",record->type,ctime(&record->eventTime));*/

        switch (record->type) {
            struct jobNewLog    *newJob;
            struct jobStartLog  *startJob;
            struct jobStatusLog *statusJob;
            struct jobFinishLog *finishJob;

        case EVENT_JOB_FINISH:
            finishJob = &(record->eventLog.jobFinishLog);

            /*printf("%s: Job <%d> finished\n",ctime(&record->eventTime),finishJob->jobId);*/
	    
	    int jobId        = finishJob->jobId;
	    int userId       = finishJob->userId;
	    char *userName    = finishJob->userName;
	    int options      = finishJob->options;
	    int numProcessors = finishJob->numProcessors;
	    int jStatus       = finishJob->jStatus;
	    time_t submitTime = finishJob->submitTime;
	    time_t startTime  = finishJob->startTime;
	    time_t endTime    = finishJob->endTime;
	    char *queue        = finishJob->queue;

	    char *subtime   = ctime(&submitTime);
	    char *starttime = ctime(&startTime);
	    char *endtime   = ctime(&endTime);

	    subtime[24]   = '\0';
	    starttime[24] = '\0';
	    endtime[24]   = '\0';
	    /*,\"%s\",\"%d\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"",*/
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
	    
	    char *commandSpool = finishJob->commandSpool;
	    char *jobFile      = finishJob->jobFile;
	    int numAskedHosts = finishJob->numAskedHosts;
	    char **askedHosts   = finishJob->askedHosts;
	    float hostFactor   = finishJob->hostFactor;
	    int numExHosts     = finishJob->numExHosts;
	    char **execHosts   = finishJob->execHosts;
	    float cpuTime      = finishJob->cpuTime;
	    char *jobName      = finishJob->jobName;
	    char *command      = finishJob->command;

	    char *askedHostsString = (char *)malloc(100 * sizeof(char));
	    char *execHostsString  = (char *)malloc(100 * sizeof(char));

	    askedHostsString[0] = '\0';
	    execHostsString[0]  = '\0';
	    int i = 0;
	    int len = 100;

	    while (i < numAskedHosts) {
	      if (i == 0) {
		strcpy(askedHostsString,*askedHosts);
	      } else {

		if (strlen(askedHostsString)+strlen(*askedHosts) +1 > len) {
		  askedHostsString = (char *)realloc(askedHostsString,strlen(askedHostsString)+strlen(*askedHosts) + 100);
		}


		strcat(askedHostsString,",");
		strcat(askedHostsString,*askedHosts);

	      }
	      askedHosts++;
	      i++;
	    }
	    /*printf("\nASKHOSTS %d %s\n",numAskedHosts,askedHostsString);*/
	      
	    i = 0;
	    len = 100;

	    while (i < numExHosts) {
	      if (i == 0) {
		strcpy(execHostsString,*execHosts);
	      } else {

		if (strlen(execHostsString)+strlen(*execHosts) +1 > len) {
		  execHostsString = (char *)realloc(execHostsString,strlen(execHostsString)+strlen(*execHosts) + 100);
		}

		strcat(execHostsString,",");
		strcat(execHostsString,*execHosts);

	      }

	      execHosts++;
	      i++;
	    }
	    /*printf("\nEXECHOSTS %d  %s\n",numExHosts,execHostsString);*/


	    printf("\"%s\",\"%s\",\"%d\",\"%s\",\"%f\",\"%d\",\"%s\",\"%f\",\"%s\",",commandSpool,jobFile,numAskedHosts,askedHostsString,hostFactor,numExHosts,execHostsString,cpuTime,jobName);

	    /*struct lsfRuage *lsfRusage = finishJob->lsfRusage;*/
	    char *dependCond   = finishJob->dependCond;
	    char *timeEvent    = finishJob->timeEvent;
	    char *preExecCmd   = finishJob->preExecCmd;
	    char *mailUser     = finishJob->mailUser;
	    char *projectName  = finishJob->projectName;
	    int exitStatus     = finishJob->exitStatus;
	    int maxNumProcessors = finishJob->maxNumProcessors;

	    printf("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%d\",\"%d\",",dependCond,timeEvent,preExecCmd,mailUser,projectName,exitStatus,maxNumProcessors);

	    char *loginShell     = finishJob->loginShell;
	    int idx              = finishJob->idx;
	    int maxRMem          = finishJob->maxRMem;
	    int maxRSwap         = finishJob->maxRSwap;
	    char *rsvId          = finishJob->rsvId;
	    char *sla            = finishJob->sla;
	    int exceptMask       = finishJob->exceptMask;
	    char *additionalInfo = finishJob->additionalInfo;

	    printf("\"%s\",\"%d\",\"%d\",\"%d\",\"%s\",\"%s\",\"%d\",\"%s\",",loginShell,idx,maxRMem,maxRSwap,rsvId,sla,exceptMask,additionalInfo);

	    int exitInfo         = finishJob->exitInfo;
	    int warningTimePeriod = finishJob->warningTimePeriod;
	    char *warningAction   = finishJob->warningAction;
	    char *chargedSAAP     = finishJob->chargedSAAP;
	    char *licenseProject  = finishJob->licenseProject;
	    char *app             = finishJob->app;
	    char *postExecCmd     = finishJob->postExecCmd;
	    int runtimeEstimation = finishJob->runtimeEstimation;
	    char *jgroup          = finishJob->jgroup;
	    int options2          = finishJob->options2;
	    char *requeueEValues   = finishJob->requeueEValues;
	    char *notifyCmd       = finishJob->notifyCmd;
	    time_t lastResizeTime  = finishJob->lastResizeTime;
	    char *jobDescription = finishJob->jobDescription;
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
	      
            continue;

        case EVENT_JOB_NEW:
            newJob = &(record->eventLog.jobNewLog);
            printf("%s: job <%d> submitted by <%s> from <%s> to <%s> queue\n",
                    ctime(&record->eventTime), newJob->jobId, newJob->userName, 
                    newJob->fromHost, newJob->queue);
            continue;

        case EVENT_JOB_START:
            startJob = &(record->eventLog.jobStartLog);
            printf("%s: job <%d> started on ",
                    ctime(&record->eventTime), newJob->jobId);
            for (i=0; i<startJob->numExHosts; i++) 
                printf("<%s> ", startJob->execHosts[i]);
            printf("\n");
            continue;

        case EVENT_JOB_STATUS:
            statusJob = &(record->eventLog.jobStatusLog);
            printf("%s: Job <%d> status changed to: ", 
                    ctime(&record->eventTime), statusJob->jobId);
            switch(statusJob->jStatus) {

            case JOB_STAT_PEND:
                printf("pending\n");
                continue;

            case JOB_STAT_RUN:
                printf("running\n");
                continue;

            case JOB_STAT_SSUSP:
            case JOB_STAT_USUSP:
            case JOB_STAT_PSUSP:
                printf("suspended\n");
                continue;

            case JOB_STAT_UNKWN:
                printf("unknown (sbatchd unreachable)\n");
                continue;

            case JOB_STAT_EXIT:
                printf("exited\n");
                continue;

            case JOB_STAT_DONE:
                printf("done\n");
                continue;

            default:
                printf("\nError: unknown job status %d\n", statusJob->jStatus);
                continue;
            }
        default:            /* only display a few selected event types*/
            continue;
        }
    }

    exit(0);
}
