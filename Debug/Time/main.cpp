#include <stdio.h>
#include <time.h>

int main(int argc, char** argv) {
    time_t ltime;
    long int raw_time;

    time(&ltime);
    printf("Current local time as unix timestamp: %li\n", ltime);

    struct tm* timeinfo = gmtime(&ltime); /* Convert to UTC */
    ltime = mktime(timeinfo); /* Store as unix timestamp */
    printf("Current UTC time as unix timestamp: %li\n", ltime);
    
    raw_time = (long int)time(NULL);

    printf("Current Long time: %d", raw_time);

    return 0;
}