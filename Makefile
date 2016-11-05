.PHONY: all


all: build/ratel-helper build/ratel


build/ratel-helper: ratel/commands/suid-helper/*.rkt ratel/ffi/libc.rkt
	raco exe -o build/ratel-helper ratel/commands/suid-helper/main.rkt
	sudo chown root:root build/ratel-helper
	sudo chmod 4755 build/ratel-helper


build/ratel: ratel/commands/*.rkt ratel/ffi/*.rkt ratel/*.rkt
	raco exe -o build/ratel ratel/commands/main.rkt
