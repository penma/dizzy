CXX?=g++
LDFLAGS?=-lSDL -lGL -lm
CXXFLAGS?=-Os -g

all: dizzy

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $<

dizzy: main.o dizzyTextures.o
	$(CXX) $(LDFLAGS) $^ -o $@

clean:
	$(RM) dizzy
