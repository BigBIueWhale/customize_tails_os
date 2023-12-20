# Compiler settings - can be customized.
CXX = g++
CXXFLAGS = -std=c++14 -Wall -Wextra -g

# Output directory
BUILDDIR = ./build

# Files
TARGET = $(BUILDDIR)/executable2
SOURCES = main.cpp

# Build target
$(TARGET): $(SOURCES)
		mkdir -p $(BUILDDIR)
		$(CXX) $(CXXFLAGS) -o $(TARGET) $(SOURCES)

# Clean up
clean:
		rm -rf $(BUILDDIR)

# Phony targets
.PHONY: clean
