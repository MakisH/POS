#VERSION=provided
VERSION=collectives
#VERSION=io

CC=mpicc
#CC=scorep mpicc

SRC_TEST=cannon_$(VERSION)

all:
	@make cannon

cannon: $(SRC_TEST:%=%.o)
	$(CC) $(CFLAGS) $(LDFLAGS) -o cannon $(SRC_TEST:%=%.o)  -lm

%.o : %.c
	$(CC) -c $(CFLAGS) $(LDFLAGS) $*.c -o $*.o

clean:
	/bin/rm -f $(SRC_TEST:%=%.o) cannon
