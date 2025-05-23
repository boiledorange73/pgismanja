# **********************************************************************
# * $Id: Makefile.in
# *
# * PostGIS - Spatial Types for PostgreSQL
# * http://postgis.refractions.net
# * Copyright 2008 Kevin Neufeld
# *
# * This is free software; you can redistribute and/or modify it under
# * the terms of the GNU General Public Licence. See the COPYING file.
# *
# **********************************************************************

CC=gcc
CFLAGS=-g -I/usr/local/include -L/usr/local/lib -R/usr/local/lib  -Wall -Wmissing-prototypes

CUNIT_LDFLAGS=
CUNIT_CPPFLAGS= -I../../../liblwgeom

IMAGES= \
	../images/de9im01.png \
	../images/de9im02.png \
	../images/st_buffer01.png \
	../images/st_buffer02.png \
	../images/st_buffer03.png \
	../images/st_buffer04.png \
	../images/st_buffer05.png \
	../images/st_buffer06.png \
	../images/st_buffer07.png \
	../images/st_buffer08.png \
	../images/st_buildarea01.png \
	../images/st_buildarea02.png \
	../images/st_closestpoint01.png \
	../images/st_closestpoint02.png \
	../images/st_centroid01.png \
	../images/st_centroid02.png \
	../images/st_centroid03.png \
	../images/st_centroid04.png \
	../images/st_contains01.png \
	../images/st_contains02.png \
	../images/st_contains03.png \
	../images/st_contains04.png \
	../images/st_contains05.png \
	../images/st_contains06.png \
	../images/st_convexhull01.png \
	../images/st_crosses01.png \
	../images/st_crosses02.png \
	../images/st_crosses03.png \
	../images/st_crosses04.png \
	../images/st_difference01.png \
	../images/st_dumppoints01.png \
	../images/st_issimple01.png \
	../images/st_issimple02.png \
	../images/st_issimple03.png \
	../images/st_issimple04.png \
	../images/st_issimple05.png \
	../images/st_issimple06.png \
	../images/st_issimple07.png \
	../images/st_isvalid01.png \
	../images/st_isvalid02.png \
	../images/st_isvalid03.png \
	../images/st_isvalid04.png \
	../images/st_isvalid05.png \
	../images/st_isvalid06.png \
	../images/st_isvalid07.png \
	../images/st_isvalid08.png \
	../images/st_linecrossingdirection01.png \
	../images/st_linecrossingdirection02.png \
	../images/st_linecrossingdirection03.png \
	../images/st_linecrossingdirection04.png \
	../images/st_line_interpolate_point01.png \
	../images/st_line_substring01.png \
	../images/st_longestline01.png \
	../images/st_longestline02.png \
	../images/st_longestline03.png \
	../images/st_minimumboundingcircle01.png \
	../images/st_shortestline01.png \
	../images/st_shortestline02.png \
	../images/st_symdifference01.png \
	../images/st_symdifference02.png \
	../images/st_touches01.png \
	../images/st_touches02.png \
	../images/st_touches03.png \
	../images/st_touches04.png \
	../images/st_touches05.png \
	../images/st_touches06.png \
	../images/st_within01.png

# Images that are created with dimensions 100x100
IMAGES_RESIZED= \
	../images/de9im03.png \
	../images/de9im04.png \
	../images/de9im05.png \
	../images/de9im06.png \
	../images/de9im07.png \
	../images/de9im08.png \
	../images/de9im09.png \
	../images/de9im10.png \
	../images/de9im11.png \
	../images/de9im12.png \
	../images/de9im13.png 

OBJS=styles.o generator.o

# Build the generator
all: generator

# generate the images
images: $(IMAGES) $(IMAGES_RESIZED)

# Command to build each of the .o files
$(OBJS): %.o: %.c
	$(CC) $(CFLAGS) $(CUNIT_CPPFLAGS) -c -o $@ $<

# Command to build each of the .wkt files
$(IMAGES): ../images/%.png: %.wkt generator styles.conf
	@./generator $<

# Command to resize each of the images
$(IMAGES_RESIZED): ../images/%.png: %.wkt generator styles.conf
	@./generator $<
	convert $@ -resize 100x100 $@

# Build the main executable
generator: ../../../liblwgeom/liblwgeom.a $(OBJS)
	$(CC) -o $@ $(OBJS) ../../../liblwgeom/liblwgeom.a -lm $(CUNIT_LDFLAGS)

# Build liblwgeom
../../../liblwgeom/liblwgeom.a:
	make -C ../../../liblwgeom liblwgeom.a

# Clean target
clean:
	@rm -f $(OBJS)
	@rm -f generator
	@rm -f tmp[0-9].png

