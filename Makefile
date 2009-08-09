LDFLAGS ?= -lGL -lglut -lm -lrt
CFLAGS  ?= -Wall -Wextra -Wno-unused -Os -g -std=gnu99

OBJFILES = main.o textures.o rotators.o render.o

all: dizzy

textures_data.h: textures_data.h-in textures/* textures/
	./makefuncs textures/ textures_data.h-in textures_data.h

rotators_data.h: rotators_data.h-in rotators/* rotators/
	./makefuncs rotators/ rotators_data.h-in rotators_data.h

textures.o: textures_data.h

rotators.o: rotators_data.h

dizzy: textures_data.h rotators_data.h $(OBJFILES)
	$(CC) $(LDFLAGS) $(OBJFILES) -o $@

clean:
	$(RM) dizzy textures_data.h rotators_data.h $(OBJFILES)
