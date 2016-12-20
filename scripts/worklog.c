/*************************************************************
 * Program	: work log creator
 * Author 	: Chauncey Yan
 * ***********************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#define BUF_SIZE 256
int main (int argc, char *argv[]){
  	int fd, num_write;
	char buf[BUF_SIZE]; 
	// open the file for writing
	if ((fd = open("/home/cyan/Desktop/worklog.log", 
					O_RDWR | O_CREAT | O_APPEND, 
					S_IRUSR | S_IWUSR)) == -1){
		perror("open");
		exit(EXIT_FAILURE);
	}
	// write the date and time
	time_t curtime = time(NULL);
	struct tm tm;
	// Convert it to local time representation.
	tm = *localtime (&curtime);
	// Print it out in a nice format.
	sprintf(buf,"%d-%d-%d %d:%d:%d\n", 
			tm.tm_year + 1900, 
			tm.tm_mon + 1, 
			tm.tm_mday, 
			tm.tm_hour, 
			tm.tm_min, 
			tm.tm_sec);
	
	if (write(fd, buf, strlen(buf)) != strlen(buf)){
		perror("Can't write the whole buf ");
		exit(EXIT_FAILURE);
	}
	memset(buf, '\0', BUF_SIZE);
	//write the command line arg to log
	for (int i = 1; i < argc; i++){
		strcpy(buf,argv[i]);
		if (i != (argc-1))
			buf[strlen(buf)] = ' ';
		if (write(fd, buf, strlen(buf)) != strlen(buf)){
			perror("Can't write the whole buf");
			exit(EXIT_FAILURE);
		}
		memset(buf, '\0', BUF_SIZE);
	}
	if (write(fd, "\n", 1) != 1){
		perror("Can't write the '\n' ");
		exit(EXIT_FAILURE);
	}
	printf("Happy~\n");
	close(fd);
	
	return 0;
}
