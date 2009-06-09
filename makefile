NAME=vbap
CSYM=vbap
NAMEB=define_loudspeakers
CSYMB=define_loudspeakers

current: pd_nt pd_darwin

# ----------------------- NT -----------------------

pd_nt: $(NAME).dll

.SUFFIXES: .dll

PDNTCFLAGS = /W3 /WX /O2 /G6 /DNT /DPD /nologo
VC="C:\Programme\Microsoft Visual Studio\VC98"

PDNTINCLUDE = /I. /Ic:\pd\tcl\include /Ic:\pd\src /I$(VC)\include /Iinclude

PDNTLDIR = $(VC)\Lib
PDNTLIB = $(PDNTLDIR)\libc.lib \
	$(PDNTLDIR)\oldnames.lib \
	$(PDNTLDIR)\kernel32.lib \
	$(PDNTLDIR)\user32.lib \
	$(PDNTLDIR)\uuid.lib \
	$(PDNTLDIR)\ws2_32.lib \
	c:\pd\bin\pd.lib \

.c.dll:
	cl $(PDNTCFLAGS) $(PDNTINCLUDE) /c $(NAME).c
	cl $(PDNTCFLAGS) $(PDNTINCLUDE) /c $(NAMEB).c
	link /dll /export:$(CSYM)_setup $(NAME).obj $(PDNTLIB)
	link /dll /export:$(CSYMB)_setup $(NAMEB).obj $(PDNTLIB)

# ----------------------- IRIX 5.x -----------------------

pd_irix5: $(NAME).pd_irix5

.SUFFIXES: .pd_irix5

SGICFLAGS5 = -o32 -DPD -DUNIX -DIRIX -O2

SGIINCLUDE =  -I../../src

.c.pd_irix5:
	cc $(SGICFLAGS5) $(SGIINCLUDE) -o $*.o -c $*.c
	ld -elf -shared -rdata_shared -o $*.pd_irix5 $*.o
	rm $*.o

# ----------------------- IRIX 6.x -----------------------

pd_irix6: $(NAME).pd_irix6

.SUFFIXES: .pd_irix6

SGICFLAGS6 = -n32 -DPD -DUNIX -DIRIX -DN32 -woff 1080,1064,1185 \
	-OPT:roundoff=3 -OPT:IEEE_arithmetic=3 -OPT:cray_ivdep=true \
	-Ofast=ip32

.c.pd_irix6:
	cc $(SGICFLAGS6) $(SGIINCLUDE) -o $*.o -c $*.c
	ld -n32 -IPA -shared -rdata_shared -o $*.pd_irix6 $*.o
	rm $*.o

# ----------------------- MAX OS X -----------------------

pd_darwin: $(NAME).pd_darwin $(NAMEB).pd_darwin

.SUFFIXES: .pd_darwin

DARWINCFLAGS = -DPD -DUNIX -DMACOSX -O2 \
    -Wall -W -Wshadow -Wstrict-prototypes \
    -Wno-unused -Wno-parentheses -Wno-switch

DARWININCLUDE =  -I../../src 

.c.pd_darwin:
	cc $(DARWINCFLAGS) $(DARWININCLUDE) -o $*.o -c $*.c
	cc -bundle -undefined suppress -flat_namespace -o $*.pd_darwin $*.o
	rm -f $*.o ../$*.pd_darwin
	ln -s $*/$*.pd_darwin ..

# ----------------------- LINUX i386 -----------------------

pd_linux: $(NAME).pd_linux $(NAMEB).pd_linux

.SUFFIXES: .pd_linux

LINUXCFLAGS = -DPD -DUNIX -O2 -funroll-loops -fomit-frame-pointer \
    -Wall -W -Wshadow -Wstrict-prototypes \
    -Wno-unused -Wno-parentheses -Wno-switch

LINUXINCLUDE =  -I../../src -I../../pd/src 

.c.pd_linux:
	cc $(LINUXCFLAGS) $(LINUXINCLUDE) -o $*.o -c $*.c
	ld --export-dynamic  -shared -o $*.pd_linux $*.o -lc -lm -L/usr/local/lib
	strip --strip-unneeded $*.pd_linux
	rm -f $*.o ../$*.pd_linux
	ln -s $*/$*.pd_linux ..

# ----------------------------------------------------------

install:
	cp vbap-*.pd ../../doc/5.reference

clean:
	rm -f *.o *.pd_* so_locations
