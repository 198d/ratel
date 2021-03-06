.PHONY: all clean


RACKET_COLLECTS_PATH=/usr/racket/collects


all: build build/ratel-helper build/ratel


build:
	mkdir build


clean:
	rm -rf build


build/ratel-helper: ratel/commands/suid-helper/*.rkt ratel/config.rkt ratel/ffi/libc.rkt ratel/ffi/libkeyutils.rkt
	raco exe -o build/ratel-helper ratel/commands/suid-helper/main.rkt
	sudo chown root:root build/ratel-helper
	sudo chmod 4755 build/ratel-helper


build/ratel: ratel/commands/*.rkt ratel/ffi/*.rkt ratel/*.rkt
	raco exe --collects-path $(RACKET_COLLECTS_PATH) -o build/ratel ratel/commands/main.rkt
