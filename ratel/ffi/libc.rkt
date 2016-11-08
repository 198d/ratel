#lang racket
(require ffi/unsafe
         ffi/unsafe/define)


(provide (all-defined-out))


(define STDIN-FILENO 0)
(define TCSANOW 0)
(define TCSAFLUSH 2)


(define MS-NOSUID 2)
(define MS-NODEV 4)


(define-ffi-definer define-libc (ffi-lib #f))


(define-cstruct _termios ([c_iflag _uint32] [c_oflag _uint32] [c_cflag _uint32]
                          [c_lflag _uint32] [c_line _ubyte]
                          [c_cc (_array _ubyte 32)] [c_ispeed _uint32]
                          [c_ospeed _uint32]))


(define-libc tcgetattr (_fun (fd : _int)
                             (termios_p : _termios-pointer) -> _int))
(define-libc tcsetattr (_fun (fd : _int) (optional_actions : _int)
                             (termios_p : _termios-pointer) -> _int))


(define-libc umask (_fun (mask : _ushort) -> _ushort))
(define-libc daemon (_fun (nochdir : _bool) (noclose : _bool) -> _int))


(define-libc mount (_fun #:save-errno 'posix
                         (source : _string) (target : _string)
                         (filesystemtype : _string) (mountflags : _ulong)
                         (data : _pointer) -> _int))
(define-libc umount (_fun #:save-errno 'posix
                          (target : _string) -> _int))


(define-libc ttyname (_fun (fd : _int) -> _string))
