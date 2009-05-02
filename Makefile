LDFLAGS ?= -lSDL -lGL -lm
CFLAGS  ?= -Os -g -std=c99

all: dizzy

dizzy: main.o dizzy_textures.o
	$(CC) $(LDFLAGS) $^ -o $@

clean:
	$(RM) dizzy
