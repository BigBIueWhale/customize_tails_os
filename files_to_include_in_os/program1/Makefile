# Compiler settings - can be customized.
CXX = g++
CXXFLAGS = -std=c++14 -Wall -Wextra -g

# Files
TARGET = executable1
SOURCES = main.cpp

# Build target
$(TARGET): $(SOURCES)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SOURCES)

# Clean up
clean:
	rm -f $(TARGET)

# Phony targets
.PHONY: clean
