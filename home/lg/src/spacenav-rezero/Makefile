all: spacenav-rezero

CC       ?= gcc
CFLAGS   ?= -g

COBJS     = src/hid.o src/spacenav-rezero.o
OBJS      = $(COBJS)
LIBS      = `pkg-config libudev --libs` -lpthread
INCLUDES ?= -Isrc/hidapi

spacenav-rezero: $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ $(LIBS) -o spacenav-rezero

$(COBJS): %.o: %.c
	$(CC) $(CFLAGS) -c $(INCLUDES) $< -o $@

clean:
	rm -f $(OBJS) spacenav-rezero

.PHONY: clean
