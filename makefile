BINDIR = bin
SRCDIR = src
INCDIR = include
OBJDIR = obj

vpath %.c $(SRCDIR)
vpath %.h $(INCDIR)
vpath %.o $(OBJDIR)

LINK_TARGET = $(BINDIR)/hello

OBJS = $(OBJDIR)/main.o \
		$(OBJDIR)/hello.o

REBUILDABLES = $(OBJS) $(LINK_TARGET)

clean: 
	rm -f $(REBUILDABLES)

all: $(LINK_TARGET)

$(LINK_TARGET): $(OBJS)
	gcc -o $@ $^

$(OBJDIR)/%.o: %.c
	gcc -c -o $@ $< -I$(INCDIR)

main.o: hello.h
