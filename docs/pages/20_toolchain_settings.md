@page docs_toolchain_settings Toolchain settings
@anchor lcc-settings
# lcc settings
```
./lcc [ option | file ]...
	except for -l, options are processed left-to-right before files
	unrecognized options are taken to be linker options
-A	warn about nonANSI usage; 2nd -A warns more
-b	emit expression-level profiling code; see bprint(1)
-Bdir/	use the compiler named `dir/rcc'
-c	compile only
-dn	set switch statement density to `n'
-debug	Turns on --debug for compiler, -y (.cdb) and -j (.noi) for linker
-Dname -Dname=def	define the preprocessor symbol `name'
-E	only run preprocessor on named .c and .h files files -> stdout
--save-preproc  Use with -E for output to *.i files instead of stdout
-g	produce symbol table information for debuggers
-help or -?	print this message
-Idir	add `dir' to the beginning of the list of #include directories
-K don't run ihxcheck test on linker ihx output
-lx	search library `x'
-m	select port and platform: "-m[port]:[plat]" ports:sm83,z80,mos6502 plats:ap,duck,gb,sms,gg,nes
-N	do not search the standard directories for #include files
-n	emit code to check for dereferencing zero pointers
-no-crt do not auto-include the gbdk crt0.o runtime in linker list
-no-libs do not auto-include the gbdk libs in linker list
-O	is ignored
-o file	leave the output in `file'
-P	print ANSI-style declarations for globals
-p -pg	emit profiling code; see prof(1) and gprof(1)
-S	compile to assembly language
-autobank auto-assign banks set to 255 (bankpack)
-static	specify static libraries (default is dynamic)
-t -tname	emit function tracing calls to printf or to `name'
-target name	is ignored
-tempdir=dir	place temporary files in `dir/'; default=/tmp
-Uname	undefine the preprocessor symbol `name'
-v	show commands as they are executed; 2nd -v suppresses execution
-w	suppress warnings
-Woarg	specify system-specific `arg'
-W[pfablim]arg	pass `arg' to the preprocessor, compiler, assembler, bankpack, linker, ihxcheck, or makebin
```
@anchor sdcc-settings
# sdcc settings
```
SDCC : z80/sm83/mos6502 4.2.2 #13350 (Linux)
published under GNU General Public License (GPL)
Usage : sdcc [options] filename
Options :-

General options:
      --help                Display this help
  -v  --version             Display sdcc's version
      --verbose             Trace calls to the preprocessor, assembler, and linker
  -V                        Execute verbosely. Show sub commands as they are run
  -d                        Output list of macro definitions in effect. Use with -E
  -D                        Define macro as in -Dmacro
  -I                        Add to the include (*.h) path, as in -Ipath
  -A                        
  -U                        Undefine macro as in -Umacro
  -M                        Preprocessor option
  -W                        Pass through options to the pre-processor (p), assembler (a) or linker (l)
      --include             Pre-include a file during pre-processing
  -S                        Compile only; do not assemble or link
  -c  --compile-only        Compile and assemble, but do not link
  -E  --preprocessonly      Preprocess only, do not compile
      --c1mode              Act in c1 mode.  The standard input is preprocessed code, the output is assembly code.
  -o                        Place the output into the given path resp. file
  -x                        Optional file type override (c, c-header or none), valid until the next -x
      --print-search-dirs   display the directories in the compiler's search path
      --vc                  messages are compatible with Micro$oft visual studio
      --use-stdout          send errors to stdout instead of stderr
      --nostdlib            Do not include the standard library directory in the search path
      --nostdinc            Do not include the standard include directory in the search path
      --less-pedantic       Disable some of the more pedantic warnings
      --disable-warning     <nnnn> Disable specific warning
      --Werror              Treat the warnings as errors
      --debug               Enable debugging symbol output
      --cyclomatic          Display complexity of compiled functions
      --std-c89             Use ISO C90 (aka ANSI C89) standard (slightly incomplete)
      --std-sdcc89          Use ISO C90 (aka ANSI C89) standard with SDCC extensions
      --std-c95             Use ISO C95 (aka ISO C94) standard (slightly incomplete)
      --std-c99             Use ISO C99 standard (incomplete)
      --std-sdcc99          Use ISO C99 standard with SDCC extensions
      --std-c11             Use ISO C11 standard (incomplete)
      --std-sdcc11          Use ISO C11 standard with SDCC extensions (default)
      --std-c2x             Use ISO C2X standard (incomplete)
      --std-sdcc2x          Use ISO C2X standard with SDCC extensions
      --fdollars-in-identifiers  Permit '$' as an identifier character
      --fsigned-char        Make "char" signed by default
      --use-non-free        Search / include non-free licensed libraries and header files

Code generation options:
  -m                        Set the port to use e.g. -mz80.
  -p                        Select port specific processor e.g. -mpic14 -p16f84
      --stack-auto          Stack automatic variables
      --xstack              Use external stack
      --int-long-reent      Use reentrant calls on the int and long support functions
      --float-reent         Use reentrant calls on the float support functions
      --xram-movc           Use movc instead of movx to read xram (xdata)
      --callee-saves        <func[,func,...]> Cause the called function to save registers instead of the caller
      --fomit-frame-pointer  Leave out the frame pointer.
      --all-callee-saves    callee will always save registers used
      --stack-probe         insert call to function __stack_probe at each function prologue
      --no-xinit-opt        don't memcpy initialized xram from code
      --no-c-code-in-asm    don't include c-code as comments in the asm file
      --no-peep-comments    don't include peephole optimizer comments
      --codeseg             <name> use this name for the code segment
      --constseg            <name> use this name for the const segment
      --dataseg             <name> use this name for the data segment

Optimization options:
      --nooverlay           Disable overlaying leaf function auto variables
      --nogcse              Disable the GCSE optimisation
      --nolabelopt          Disable label optimisation
      --noinvariant         Disable optimisation of invariants
      --noinduction         Disable loop variable induction
      --noloopreverse       Disable the loop reverse optimisation
      --no-peep             Disable the peephole assembly file optimisation
      --no-reg-params       On some ports, disable passing some parameters in registers
      --peep-asm            Enable peephole optimization on inline assembly
      --peep-return         Enable peephole optimization for return instructions
      --no-peep-return      Disable peephole optimization for return instructions
      --peep-file           <file> use this extra peephole file
      --opt-code-speed      Optimize for code speed rather than size
      --opt-code-size       Optimize for code size rather than speed
      --max-allocs-per-node  Maximum number of register assignments considered at each node of the tree decomposition
      --nolospre            Disable lospre
      --allow-unsafe-read   Allow optimizations to read any memory location anytime
      --nostdlibcall        Disable optimization of calls to standard library

Internal debugging options:
      --dump-ast            Dump front-end AST before generating i-code
      --dump-i-code         Dump the i-code structure at all stages
      --dump-graphs         Dump graphs (control-flow, conflict, etc)
      --i-code-in-asm       Include i-code as comments in the asm file
      --fverbose-asm        Include code generator comments in the asm output

Linker options:
  -l                        Include the given library in the link
  -L                        Add the next field to the library search path
      --lib-path            <path> use this path to search for libraries
      --out-fmt-ihx         Output in Intel hex format
      --out-fmt-s19         Output in S19 hex format
      --xram-loc            <nnnn> External Ram start location
      --xram-size           <nnnn> External Ram size
      --iram-size           <nnnn> Internal Ram size
      --xstack-loc          <nnnn> External Stack start location
      --code-loc            <nnnn> Code Segment Location
      --code-size           <nnnn> Code Segment size
      --stack-loc           <nnnn> Stack pointer initial value
      --data-loc            <nnnn> Direct data start location
      --idata-loc           
      --no-optsdcc-in-asm   Do not emit .optsdcc in asm

Special options for the z80 port:
      --callee-saves-bc     Force a called function to always save BC
      --portmode=           Determine PORT I/O mode (z80/z180)
      -bo                   <num> use code bank <num>
      -ba                   <num> use data bank <num>
      --asm=                Define assembler name (rgbds/asxxxx/isas/z80asm/gas)
      --codeseg             <name> use this name for the code segment
      --constseg            <name> use this name for the const segment
      --dataseg             <name> use this name for the data segment
      --no-std-crt0         Do not link default crt0.rel
      --reserve-regs-iy     Do not use IY (incompatible with --fomit-frame-pointer)
      --fno-omit-frame-pointer  Do not omit frame pointer
      --emit-externs        Emit externs list in generated asm
      --legacy-banking      Use legacy method to call banked functions
      --nmos-z80            Generate workaround for NMOS Z80 when saving IFF2
      --sdcccall            Set ABI version for default calling convention
      --allow-undocumented-instructions  Allow use of undocumented instructions

Special options for the sm83 port:
      -bo                   <num> use code bank <num>
      -ba                   <num> use data bank <num>
      --asm=                Define assembler name (rgbds/asxxxx/isas/z80asm/gas)
      --callee-saves-bc     Force a called function to always save BC
      --codeseg             <name> use this name for the code segment
      --constseg            <name> use this name for the const segment
      --dataseg             <name> use this name for the data segment
      --no-std-crt0         Do not link default crt0.rel
      --legacy-banking      Use legacy method to call banked functions
      --sdcccall            Set ABI version for default calling convention

Special options for the mos6502 port:
      --model-small         8-bit address space for data
      --model-large         16-bit address space for data (default)
      --no-std-crt0         Do not link default crt0.rel
```
@anchor sdasgb-settings
# sdasgb settings
```

sdas Assembler V02.00 + NoICE + SDCC mods  (GameBoy)


Copyright (C) 2012  Alan R. Baldwin
This program comes with ABSOLUTELY NO WARRANTY.

Usage: [-Options] [-Option with arg] file
Usage: [-Options] [-Option with arg] outfile file1 [file2 ...]
  -h   or NO ARGUMENTS  Show this help list
Input:
  -I   Add the named directory to the include file
       search path.  This option may be used more than once.
       Directories are searched in the order given.
Output:
  -l   Create list   file/outfile[.lst]
  -o   Create object file/outfile[.rel]
  -s   Create symbol file/outfile[.sym]
Listing:
  -d   Decimal listing
  -q   Octal   listing
  -x   Hex     listing (default)
  -b   Display .define substitutions in listing
  -bb  and display without .define substitutions
  -c   Disable instruction cycle count in listing
  -f   Flag relocatable references by  `   in listing file
  -ff  Flag relocatable references by mode in listing file
  -p   Disable automatic listing pagination
  -u   Disable .list/.nlist processing
  -w   Wide listing format for symbol table
Assembly:
  -v   Enable out of range signed / unsigned errors
Symbols:
  -a   All user symbols made global
  -g   Undefined symbols made global
  -n   Don't resolve global assigned value symbols
  -z   Disable case sensitivity for symbols
Debugging:
  -j   Enable NoICE Debug Symbols
  -y   Enable SDCC  Debug Symbols

```
@anchor sdasz80-settings
# sdasz80 settings
```

sdas Assembler V02.00 + NoICE + SDCC mods  (GameBoy)


Copyright (C) 2012  Alan R. Baldwin
This program comes with ABSOLUTELY NO WARRANTY.

Usage: [-Options] [-Option with arg] file
Usage: [-Options] [-Option with arg] outfile file1 [file2 ...]
  -h   or NO ARGUMENTS  Show this help list
Input:
  -I   Add the named directory to the include file
       search path.  This option may be used more than once.
       Directories are searched in the order given.
Output:
  -l   Create list   file/outfile[.lst]
  -o   Create object file/outfile[.rel]
  -s   Create symbol file/outfile[.sym]
Listing:
  -d   Decimal listing
  -q   Octal   listing
  -x   Hex     listing (default)
  -b   Display .define substitutions in listing
  -bb  and display without .define substitutions
  -c   Disable instruction cycle count in listing
  -f   Flag relocatable references by  `   in listing file
  -ff  Flag relocatable references by mode in listing file
  -p   Disable automatic listing pagination
  -u   Disable .list/.nlist processing
  -w   Wide listing format for symbol table
Assembly:
  -v   Enable out of range signed / unsigned errors
Symbols:
  -a   All user symbols made global
  -g   Undefined symbols made global
  -n   Don't resolve global assigned value symbols
  -z   Disable case sensitivity for symbols
Debugging:
  -j   Enable NoICE Debug Symbols
  -y   Enable SDCC  Debug Symbols

```
@anchor bankpack-settings
# bankpack settings
```
bankalloc [options] objfile1 objfile2 etc
Use: Read .o files and auto-assign areas with bank=255.
     Typically called by Lcc compiler driver before linker.

Options
-h            : Show this help
-lkin=<file>  : Load object files specified in linker file <file>
-lkout=<file> : Write list of object files out to linker file <file>
-yt<mbctype>  : Set MBC type per ROM byte 149 in Decimal or Hex (0xNN)
               ([see pandocs](https://gbdev.io/pandocs/The_Cartridge_Header.html#0147---cartridge-type))
-mbc=N        : Similar to -yt, but sets MBC type directly to N instead
               of by intepreting ROM byte 149
               mbc1 will exclude banks {0x20,0x40,0x60} max=127, 
               mbc2 max=15, mbc3 max=127, mbc5 max=255 (not 511!) 
-min=N        : Min assigned ROM bank is N (default 1)
-max=N        : Max assigned ROM bank is N, error if exceeded
-ext=<.ext>   : Write files out with <.ext> instead of source extension
-path=<path>  : Write files out to <path> (<path> *MUST* already exist)
-sym=<prefix> : Add symbols starting with <prefix> to match + update list.
               Default entry is "___bank_" (see below)
-cartsize     : Print min required cart size as "autocartsize:<NNN>"
-plat=<plat>  : Select platform specific behavior (default:gb) (gb,sms)
-random       : Distribute banks randomly for testing (honors -min/-max)
-reserve=<b:n>: Reserve N bytes (hex) in bank B (decimal)
                Ex: -reserve=105:30F reserves 0x30F bytes in bank 105
-v            : Verbose output, show assignments

Example: "bankpack -ext=.rel -path=some/newpath/ file1.o file2.o"
Unless -ext or -path specify otherwise, input files are overwritten.

Default MBC type is not set. It *must* be specified by -mbc= or -yt!

The following will have FF and 255 replaced with the assigned bank:
A _CODE_255 size <size> flags <flags> addr <address>
S b_<function name> Def0000FF
S ___bank_<const name> Def0000FF
    (Above can be made by: const void __at(255) __bank_<const name>;
```
@anchor sdldgb-settings
# sdldgb settings
```

sdld Linker V03.00 + NoICE + sdld

Usage: [-Options] [-Option with arg] file
Usage: [-Options] [-Option with arg] outfile file1 [file2 ...]
Startup:
  -p   Echo commands to stdout (default)
  -n   No echo of commands to stdout
Alternates to Command Line Input:
  -c                   ASlink >> prompt input
  -f   file[.lk]       Command File input
Libraries:
  -k   Library path specification, one per -k
  -l   Library file specification, one per -l
Relocation:
  -b   area base address = expression
  -g   global symbol = expression
Map format:
  -m   Map output generated as (out)file[.map]
  -w   Wide listing format for map file
  -x   Hexadecimal (default)
  -d   Decimal
  -q   Octal
Output:
  -i   Intel Hex as (out)file[.ihx]
  -s   Motorola S Record as (out)file[.s19]
  -j   NoICE Debug output as (out)file[.noi]
  -y   SDCDB Debug output as (out)file[.cdb]
List:
  -u   Update listing file(s) with link data as file(s)[.rst]
Case Sensitivity:
  -z   Disable Case Sensitivity for Symbols
End:
  -e   or null line terminates input

```
@anchor sdldz80-settings
# sdldz80 settings
```

sdld Linker V03.00 + NoICE + sdld

Usage: [-Options] [-Option with arg] file
Usage: [-Options] [-Option with arg] outfile file1 [file2 ...]
Startup:
  -p   Echo commands to stdout (default)
  -n   No echo of commands to stdout
Alternates to Command Line Input:
  -c                   ASlink >> prompt input
  -f   file[.lk]       Command File input
Libraries:
  -k   Library path specification, one per -k
  -l   Library file specification, one per -l
Relocation:
  -b   area base address = expression
  -g   global symbol = expression
Map format:
  -m   Map output generated as (out)file[.map]
  -w   Wide listing format for map file
  -x   Hexadecimal (default)
  -d   Decimal
  -q   Octal
Output:
  -i   Intel Hex as (out)file[.ihx]
  -s   Motorola S Record as (out)file[.s19]
  -j   NoICE Debug output as (out)file[.noi]
  -y   SDCDB Debug output as (out)file[.cdb]
List:
  -u   Update listing file(s) with link data as file(s)[.rst]
Case Sensitivity:
  -z   Disable Case Sensitivity for Symbols
End:
  -e   or null line terminates input

```
@anchor ihxcheck-settings
# ihxcheck settings
```
ihx_check input_file.ihx [options]

Options
-h : Show this help
-e : Treat warnings as errors

Use: Read a .ihx and warn about overlapped areas.
Example: "ihx_check build/MyProject.ihx"
```
@anchor makebin-settings
# makebin settings
Also see @ref setting_mbc_and_rom_ram_banks
```
makebin: convert a Intel IHX file to binary or GameBoy format binary.
Usage: makebin [options] [<in_file> [<out_file>]]
Options:
  -p             pack mode: the binary file size will be truncated to the last occupied byte
  -s romsize     size of the binary file (default: rom banks * 16384)
  -Z             generate GameBoy format binary file
  -S             generate Sega Master System format binary file
  -N             generate Famicom/NES format binary file
  -o bytes       skip amount of bytes in binary file
SMS format options (applicable only with -S option):
  -xo n          rom size (0xa-0x2) (default: 0xc)
  -xj n          set region code (3-7) (default: 4)
  -xv n          version number (0-15) (default: 0)
GameBoy format options (applicable only with -Z option):
  -yo n          number of rom banks (default: 2) (autosize: A)
  -ya n          number of ram banks (default: 0)
  -yt n          MBC type (default: no MBC)
  -yl n          old licensee code (default: 0x33)
  -yk cc         new licensee string (default: 00)
  -yn name       cartridge name (default: none)
  -yc            GameBoy Color compatible
  -yC            GameBoy Color only
  -ys            Super GameBoy
  -yS            Convert .noi file named like input file to .sym
  -yj            set non-Japanese region flag
  -yN            do not copy big N validation logo into ROM header
  -yp addr=value Set address in ROM to given value (address 0x100-0x1FE)
Arguments:
  <in_file>      optional IHX input file, '-' means stdin. (default: stdin)
  <out_file>     optional output file, '-' means stdout. (default: stdout)
```
@anchor makecom-settings
# makecom settings
```
makecom image.rom image.noi output.com
Use: convert a binary .rom file to .msxdos com format.
```
@anchor gbcompress-settings
# gbcompress settings
```
gbcompress [options] infile outfile
Use: compress a binary file and write it out.

Options
-h       : Show this help screen
-d       : Decompress (default is compress)
-v       : Verbose output
--cin    : Read input as .c source format (8 bit char ONLY, uses first array found)
--cout   : Write output in .c / .h source format (8 bit char ONLY) 
--varname=<NAME> : specify variable name for c source output
--alg=<type>     : specify compression type: 'rle', 'gb' (default)
--bank=<num>     : Add Bank Ref: 1 - 511 (default is none, with --cout only)
Example: "gbcompress binaryfile.bin compressed.bin"
Example: "gbcompress -d compressedfile.bin decompressed.bin"
Example: "gbcompress --alg=rle binaryfile.bin compressed.bin"

The default compression (gb) is the type used by gbtd/gbmb
The rle compression is Amiga IFF style
```
@anchor png2asset-settings
# png2asset settings
```
usage: png2asset    <file>.png [options]
-c                  ouput file (default: <png file>.c)
-sw <width>         metasprites width size (default: png width)
-sh <height>        metasprites height size (default: png height)
-sp <props>         change default for sprite OAM property bytes (in hex) (default: 0x00)
-px <x coord>       metasprites pivot x coordinate (default: metasprites width / 2)
-py <y coord>       metasprites pivot y coordinate (default: metasprites height / 2)
-pw <width>         metasprites collision rect width (default: metasprites width)
-ph <height>        metasprites collision rect height (default: metasprites height)
-spr8x8             use SPRITES_8x8
-spr8x16            use SPRITES_8x16 (this is the default)
-spr16x16msx        use SPRITES_16x16
-b <bank>           bank (default 0)
-keep_palette_order use png palette
-repair_indexed_pal try to repair indexed tile palettes (implies "-keep_palette_order")
-noflip             disable tile flip
-map                Export as map (tileset + bg)
-use_map_attributes Use CGB BG Map attributes
-use_nes_attributes Use NES BG Map attributes
-use_nes_colors     Convert RGB color values to NES PPU colors
-use_structs        Group the exported info into structs (default: false) (used by ZGB Game Engine)
-bpp                bits per pixel: 1, 2, 4 (default: 2)
-max_palettes       max number of palettes allowed (default: 8)
                    (note: max colors = max_palettes x num colors per palette)
-pack_mode          gb, sgb, sms, 1bpp (default: gb)
-tile_origin        tile index offset for maps (default: 0)
-tiles_only         export tile data only
-maps_only          export map tilemap only
-metasprites_only   export metasprite descriptors only
-source_tileset     use source tileset (image with common tiles)
-keep_duplicate_tiles   do not remove duplicate tiles (default: not enabled)
-bin                export to binary format
-transposed         export transposed (column-by-column instead of row-by-row)
```
