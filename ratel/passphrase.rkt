#lang racket
(require ffi/unsafe
         "ffi/libc.rkt"
         "ffi/libecryptfs.rkt"
         "ffi/libkeyutils.rkt")


(provide read-passphrase
         generate-passphrase-sig
         add-passphrase-to-keyring
         remove-passphrase-from-keyring)


(define (read-passphrase [prompt-string "Passphrase: "])
  (write-string prompt-string)
  (let ([current-termios (cast (malloc _termios) _pointer _termios-pointer)]
        [saved-termios (cast (malloc _termios) _pointer _termios-pointer)]
        [passphrase #f])
    (define (reset-attr)
      (tcsetattr STDIN-FILENO TCSANOW saved-termios))
    (with-handlers ([(lambda (exn) #t) (lambda (exn)
                                         (reset-attr)
                                         (raise exn))])
      (tcgetattr STDIN-FILENO current-termios)
      (memcpy saved-termios current-termios 1 _termios)
      (set-termios-c_lflag! current-termios
                            (bitwise-and (termios-c_lflag current-termios)
                                         (bitwise-not 8)))
      (tcsetattr STDIN-FILENO TCSAFLUSH current-termios)
      (set! passphrase (read-line))
      (write-string "\n")
      (reset-attr)
    passphrase)))


(define (generate-passphrase-sig
          passphrase #:salt [salt (make-bytes ECRYPTFS-SALT-SIZE)])
  (let ([sig-pointer (cast (malloc ECRYPTFS-SIG-SIZE-HEX) _pointer _bytes)]
        [fekek-pointer (cast (malloc ECRYPTFS-MAX-KEY-BYTES) _pointer _bytes)])
    (generate_passphrase_sig sig-pointer fekek-pointer salt passphrase)
    (values (cast sig-pointer _bytes _string)
            fekek-pointer)))


(define (add-passphrase-to-keyring
          passphrase #:salt [salt (make-bytes ECRYPTFS-SALT-SIZE)]
          #:keyring [keyring KEY-SPEC-USER-KEYRING]
          #:timeout [timeout 0])
  (let-values ([(auth-tok-pointer) (malloc SIZEOF-STRUCT-ECRYPTFS-AUTH-TOK)]
               [(passphrase-sig fekek)
                (generate-passphrase-sig passphrase #:salt salt)])
    (generate_payload auth-tok-pointer passphrase-sig salt fekek)
    (keyctl_set_timeout
      (add_key "user" passphrase-sig auth-tok-pointer
               SIZEOF-STRUCT-ECRYPTFS-AUTH-TOK keyring)
      timeout)
    passphrase-sig))


(define (remove-passphrase-from-keyring
          signature
          #:keyring [keyring KEY-SPEC-USER-KEYRING])
  (void
    (keyctl_unlink (keyctl_search keyring "user" signature 0) keyring)))
