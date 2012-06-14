#include <stdio.h>
#include <stdlib.h>
#include <lsf/lsbatch.h>

int main(int argc, char **argv) {
	char usagestr[256];
	
	LS_LONG_INT jobid;

	struct jobInfoEnt *job;
	int    more;
	int    i;
	
	if (lsb_init(argv[0]) < 0) {
		lsb_perror("lsb_init() failed");
		exit(-1);
	}
	
	sprintf(usagestr, "*** ERROR *** usage: %s JOB_ID\n", argv[0]);

	if (argc < 2) {
		fprintf(stderr, usagestr);
		exit(-1);
	}

	jobid = atoi(argv[1]);

	if (lsb_openjobinfo(jobid, NULL, ALL_USERS, NULL, NULL, ALL_JOB) < 0) {  //ALL_USERS = "all"
		lsb_perror("lsb_openjobinfo() failed");
		exit(-1);
	}

	for(;;) {
		job = lsb_readjobinfo(&more);   /* get the job details */
		if (job == NULL) {
			lsb_perror("lsb_readjobinfo() failed");
			exit(-1);
		}
		
		printf("user: %s\n", job->user);
		
		printf("command: %s\n", (&job->submit)->command);
		
		printf("hosts:\n");
		for (i=0; i < job->numExHosts; i++) printf("\t%s\n", job->exHosts[i]);

		if (!more) break;
	}

	lsb_closejobinfo();
}
