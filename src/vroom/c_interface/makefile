# This file is part of VROOM.
#
# Copyright (c) 2015-2018, Julien Coupey.
# All rights reserved (see LICENSE).

# Variables.
VROOMDIR = /Users/vitornesello/Applications/gitCode/vroom/
# VROOMDIR = /Users/itahiri/GITREP/vroom
VROOMSRC = $(VROOMDIR)/src
CXX ?= g++
CXXFLAGS = -MMD -MP -I$(VROOMSRC) -std=c++14 -Wextra -Wpedantic -Wall -O3 -fpic
LDLIBS = -lboost_system -lpthread

# Using all cpp files in VRROMDIR.
LIBVROOM = $(VROOMDIR)/lib/libvroom.dylib
LIBINTFC = ./libvroominterface.dylib # dylib for the interface that uses vroom dylib
SRC = $(wildcard $(VROOMSRC)/*.cpp)\
			$(wildcard $(VROOMSRC)/algorithms/*.cpp)\
			$(wildcard $(VROOMSRC)/routing/*.cpp)\
			$(wildcard $(VROOMSRC)/problems/*.cpp)\
			$(wildcard $(VROOMSRC)/problems/*/*.cpp)\
			$(wildcard $(VROOMSRC)/problems/*/heuristics/*.cpp)\
			$(wildcard $(VROOMSRC)/problems/*/local_search/*.cpp)\
			$(wildcard $(VROOMSRC)/structures/abstract/*.cpp)\
			$(wildcard $(VROOMSRC)/structures/vroom/*.cpp)\
			$(wildcard $(VROOMSRC)/structures/vroom/input/*.cpp)\
			$(wildcard $(VROOMSRC)/structures/vroom/solution/*.cpp)\
			$(wildcard $(VROOMSRC)/structures/*.cpp)\
			$(wildcard $(VROOMSRC)/utils/*.cpp)\


# Checking for libosrm
ifeq ($(shell pkg-config --exists libosrm && echo 1),1)
	LDLIBS += $(shell pkg-config --libs libosrm) -lboost_filesystem -lboost_iostreams -lboost_thread -lrt -ltbb
	CXXFLAGS += $(shell pkg-config --cflags libosrm) -D LIBOSRM=true
else
	SRC := $(filter-out $(VROOMSRC)/routing/libosrm_wrapper.cpp, $(SRC))
endif

# for compiling VROOM LIB
OBJ = $(SRC:.cpp=.o)
DEPS = $(SRC:.cpp=.d)

# Main targets.
all : $(LIBVROOM) $(LIBINTFC)

$(LIBVROOM) : $(OBJ)
	mkdir -p $(@D)
	g++ -dynamiclib -o $@ $^ $(LDLIBS)

# $(LIBINTFC) : ./vroom_c_inferface.o
$(LIBINTFC) : $(LIBVROOM) ./vroom_c_inferface.o
	mkdir -p $(@D)
	g++ -dynamiclib -o $@ $^ $(LDLIBS)

# Building .o files.
%.o : %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

-include ${DEPS}

clean :
	$(RM) $(OBJ) $(DEPS)
	$(RM) $(LIBVROOM) $(LIBINTFC)
