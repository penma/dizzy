LDFLAGS ?= -lGL -lglut -lm -lrt
CFLAGS  ?= -Wall -Wextra -Os -g -std=gnu99

OBJFILES = main.o dizzy_textures.o dizzy_render.o

all: dizzy

textures_data.h:
	./maketextures

dizzy: textures_data.h $(OBJFILES)
	$(CC) $(LDFLAGS) $(OBJFILES) -o $@

clean:
	$(RM) dizzy textures_data.h $(OBJFILES)
