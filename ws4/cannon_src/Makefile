VERSION=provided
#VERSION=collectives
#VERSION=io

ARCH=sb
#ARCH=hw

CC=mpicc
SCOREP_SUFFIX=

#CC=scorep mpicc
#SCOREP_SUFFIX=_scorep

SRC_TEST=cannon_$(VERSION)

CFLAGS=-Wno-unused-result

all:
	@make cannon

cannon: $(SRC_TEST:%=%.o)
	$(CC) $(CFLAGS) $(LDFLAGS) -o cannon_$(VERSION)_$(ARCH)$(SCOREP_SUFFIX) $(SRC_TEST:%=%.o)  -lm

%.o : %.c
	$(CC) -c $(CFLAGS) $(LDFLAGS) $*.c -o $*.o

clean:
	/bin/rm -f $(SRC_TEST:%=%.o) cannon_$(VERSION)_$(ARCH)$(SCOREP_SUFFIX)

# Shortcut to "make clean && make".
fresh: clean all
