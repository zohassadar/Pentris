WINDOWS := $(shell which wine ; echo $$?)
UNAME_S := $(shell uname -s)

pentris_obj := main.o pentris-ram.o pentris.o
cc65Path := tools/cc65

ifeq (flags,$(firstword $(MAKECMDGOALS)))
  FLAGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(FLAGS):dummy;@:)
  FLAG_ARGS := $(addprefix -D ,$(FLAGS))
endif

# Hack for OSX
ifeq ($(UNAME_S),Darwin)
	SHA1SUM := shasum
else
	SHA1SUM := sha1sum
endif

# Programs
ifeq ($(WINDOWS),1)
  WINE :=
else
  WINE := wine
endif

CA65 := $(WINE) $(cc65Path)/bin/ca65
LD65 := $(WINE) $(cc65Path)/bin/ld65

nesChrEncode := python3 tools/nes-util/nes_chr_encode.py
pythonExecutable := python

pentris.nes: pentris.o main.o pentris-ram.o

pentris:= pentris.nes

.SUFFIXES:
.SECONDEXPANSION:
.PRECIOUS:
.SECONDARY:
.PHONY: dummy clean compare tools flags patch


CAFLAGS = -g
LDFLAGS =


flags: CAFLAGS += $(FLAG_ARGS)
flags: $(pentris)
	@echo Flags enabled:  $(FLAGS)

compare: $(pentris)
	$(SHA1SUM) -c pentris.sha1

clean:
	rm -f  $(pentris_obj) $(pentris) *.d pentris.dbg pentris.lbl gfx/*.chr gfx/nametables/*.bin
	$(MAKE) clean -C tools/cTools/

tools:
	$(MAKE) -C tools/cTools/

patch: $(pentris_obj)
patch: 
	tools/flips-linux --create clean.nes $(pentris) pentris.bps


# Build tools when building the rom.
# This has to happen before the rules are processed, since that's when scan_includes is run.
ifeq (,$(filter clean tools/cTools/,$(MAKECMDGOALS)))
$(info $(shell $(MAKE) -C tools/cTools/))
endif


%.o: dep = $(shell tools/cTools/scan_includes $(@D)/$*.asm)
$(pentris_obj): %.o: %.asm $$(dep)
		$(CA65) $(CAFLAGS) $*.asm -o $@

%: %.cfg
		$(LD65) $(LDFLAGS) -Ln $(basename $@).lbl --dbgfile $(basename $@).dbg -o $@ -C $< $(pentris_obj)

%.bin: %.py
		$(pythonExecutable) $?

%.asm: %.py
		$(pythonExecutable) $?

%.chr: %.png
		$(nesChrEncode) $< $@

orientation/orientation_table.py: orientation/orientations.py
		touch orientation/orientation_table.py

orientation/spawn_table.py: orientation/orientations.py
		touch orientation/spawn_table.py
	
orientation/rotation_table.py: orientation/orientations.py
		touch orientation/rotation_table.py

orientation/spawn_from_orientation.py: orientation/orientations.py
		touch orientation/spawn_from_orientation.py

orientation/type_from_orientation.py: orientation/orientations.py
		touch orientation/type_from_orientation.py

orientation/orientation_to_next_offset.py: orientation/orientations.py
		touch orientation/orientation_to_next_offset.py

orientation/hidden_piece_id.py: orientation/orientations.py
		touch orientation/hidden_piece_id.py