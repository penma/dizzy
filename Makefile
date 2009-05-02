CXX?=g++
LDFLAGS?=-lSDL -lGL -lm
CXXFLAGS?=-Os -g

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $<

dizzy: main.o dizzyTextures.o
	$(CXX) $(LDFLAGS) $^ -o $@
