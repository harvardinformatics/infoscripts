/* Simple C program that connects to MySQL Database server*/

#include<mysql.h>
#include<stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]){
   MYSQL     *conn;
   MYSQL_RES *res;
   MYSQL_ROW row;
   char      *server   ="localhost";
   char      *user     ="root";
   char      *password ="98lsf76";/* set me first */
   char      *database ="lsf";

   conn =  mysql_init(NULL);

   /* Connect to database */
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

   char *qstr;
   
   qstr = (char *)malloc(200*sizeof(char));

   strcpy(qstr,"select user_internal_id from user where user_name = '");
   strcat(qstr,argv[1]);
   strcat(qstr,"'");

   printf("Query is %s\n",qstr);

   /* send SQL query */

   if (mysql_query(conn,qstr)){
     fprintf(stderr,"%s\n",mysql_error(conn));
     exit(1);
   } 
   res = mysql_use_result(conn);
   
   /* output table name */

   while((row = mysql_fetch_row(res))!= NULL) {
     printf("User %s\n",row[0]);
   }

   /* close connection */
   mysql_free_result(res);
   mysql_close(conn); 
   
   return 1;
}
