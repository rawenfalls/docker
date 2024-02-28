CC = gcc
LIB = ../lib/libakrypt/*.c
TARGETS = make_sign_key
SRCS = make_sign_key.c
CFLAGS += -I../lib/libakrypt

MAKEFLAGS += -B

.PHONY: all build done clean debug build_all long

all: CFLAGS += -O2
all: build done

build: 
	@$(CC) $(CFLAGS) -o make_sign_key make_sign_key.c $(LIB)

build_all: $(TARGETS)

$(TARGETS): $(SRCS)
	@$(CC) $(CFLAGS) -o $@ $(filter $@%, $(SRCS)) $(LIB)

done:	
	$(info DONE)

done512:	
	$(info DONE512)

clean:
	@rm -rf $(TARGETS)
	$(info CLEAN DONE)

debug: CFLAGS += -DDEBUG
debug: CFLAGS += -g -Wall
debug: build done

long: CFLAGS += -DLONG512 
long: build done512