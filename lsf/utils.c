#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "utils.h"

char *read_line(FILE *file) {

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

char *next_field(char *str, int *pos) {

  char *outstr = NULL;
  int   n      = 0;
  int   i      = *pos;

  while (i < strlen(str) && str[i]  != ' ') {
    if (outstr == NULL) {
      n = 0;
      outstr = (char *)malloc(10*sizeof(char));

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

    words[count-1] = malloc((strlen(word)+1)*sizeof(char));
    strcpy(words[count-1],word);
    free(word);
  }
  count++;
  words = (char **)realloc(words,sizeof(char *)*(count));
  words[count-1] = NULL;
  free(word);
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
