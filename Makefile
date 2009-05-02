LDFLAGS ?= -lSDL -lGL -lm
CFLAGS  ?= -Os -g -std=c99
OBJFILES = main.o dizzy_textures.o

all: dizzy

dizzy: $(OBJFILES)
	$(CC) $(LDFLAGS) $^ -o $@

clean:
	$(RM) dizzy $(OBJFILES)
