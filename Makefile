LDFLAGS ?= -lSDL -lGL -lm
CFLAGS  ?= -Wall -Wextra -Os -g -std=gnu99

CC = $(shell which clang || which cc)

OBJFILES = main.o dizzy_textures.o

all: dizzy

dizzy: $(OBJFILES)
	$(CC) $(LDFLAGS) $^ -o $@

clean:
	$(RM) dizzy $(OBJFILES)
