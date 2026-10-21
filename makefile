CXX      := g++
CXXFLAGS := -std=c++17 -O2 -Wall -Wextra -I.

.PHONY: all run test clean

all: app tests

app: main.cpp analyzer.cpp analyzer.h
	$(CXX) $(CXXFLAGS) main.cpp analyzer.cpp -o $@

tests: test_trip_analyzer.cpp analyzer.cpp analyzer.h catch_amalgamated.cpp catch_amalgamated.hpp
	$(CXX) $(CXXFLAGS) test_trip_analyzer.cpp analyzer.cpp catch_amalgamated.cpp -o $@

run: app
	./app

test: tests
	FAST=1 ./tests

clean:
	rm -f app tests app.exe tests.exe
