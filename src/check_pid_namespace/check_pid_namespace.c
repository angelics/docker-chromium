// https://chromium.googlesource.com/chromium/src/+/master/docs/linux/pid_namespace_support.md

#define _GNU_SOURCE
#include <unistd.h>
#include <sched.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <sys/wait.h>

#if !defined(CLONE_NEWPID)
#define CLONE_NEWPID 0x20000000
#endif

int worker(void* arg) {
    const pid_t pid = getpid();
    if (pid == 1) {
        printf("PID namespace is working.\n");
    }
    else {
        printf("PID namespace is not working, child pid: %d.\n", pid);
    }

    return 0;
}

int main() {
    int retval = 0;

    char stack[8192];
    const pid_t child = clone(worker, stack + sizeof(stack), CLONE_NEWPID, NULL);
    if (child == -1) {
	if (errno == EINVAL) {
            // Not supported.
	    printf("PID namespace not supported.\n");
            retval = 2;
	}
	else {
            // Supported, but something went wrong.
            printf("PID namespace supported, but failed: %s.\n", strerror(errno));
            retval = 3;
	}
    }
    else {
        printf("PID namespace supported.\n");
    }

    waitpid(child, NULL, 0);

    return retval;
}