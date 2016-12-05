#lang racket
(require ffi/unsafe
         "ffi/libc.rkt"
         "ffi/libecryptfs.rkt"
         "ffi/libkeyutils.rkt")


(provide read-passphrase
         generate-passphrase-sig
         add-passphrase-to-keyring
         remove-passphrase-from-keyring)


(define default-keyring
  (make-parameter
    (case (getenv "RATEL_DEFAULT_KEYRING")
      [("USER") KEY-SPEC-USER-KEYRING]
      [("SESSION") KEY-SPEC-SESSION-KEYRING]
      [else KEY-SPEC-USER-KEYRING])))


(define (read-passphrase mount-name [prompt-string "Passphrase"])
  (let ([current-termios (cast (malloc _termios) _pointer _termios-pointer)]
        [pinentry (pinentry-connect)])
    (tcgetattr STDIN-FILENO current-termios)
    (with-handlers ([(lambda (exn) #t) (lambda (exn)
                                         (pinentry-disconnect pinentry)
                                         (tcsetattr STDIN-FILENO TCSANOW
                                                    current-termios)
                                         (raise exn))])
      (pinentry-exec pinentry "SETDESC"
                     (format "Enter eCryptfs passphrase for '~a'."
                             mount-name))
      (pinentry-exec pinentry "SETPROMPT" prompt-string)
      (let-values ([(success data message) (pinentry-exec pinentry "GETPIN")])
        (first data)))))


(define (generate-passphrase-sig
          passphrase #:salt [salt (make-bytes ECRYPTFS-SALT-SIZE)])
  (let ([sig-pointer (cast (malloc ECRYPTFS-SIG-SIZE-HEX) _pointer _bytes)]
        [fekek-pointer (cast (malloc ECRYPTFS-MAX-KEY-BYTES) _pointer _bytes)])
    (generate_passphrase_sig sig-pointer fekek-pointer salt passphrase)
    (values (cast sig-pointer _bytes _string)
            fekek-pointer)))


(define (add-passphrase-to-keyring
          passphrase #:salt [salt (make-bytes ECRYPTFS-SALT-SIZE)]
          #:keyring [keyring (default-keyring)]
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
          #:keyring [keyring (default-keyring)])
  (void
    (keyctl_unlink (keyctl_search keyring "user" signature 0) keyring)))


(define-struct pinentry (subproc stdout stdin stderr))


(define (pinentry-write-command pinentry command)
  (let ([output-port (pinentry-stdin pinentry)])
    (write-string command output-port)
    (newline output-port)
    (flush-output output-port)))


(define (pinentry-read-response pinentry)
  (define (message-result message)
    (if (= 0 (string-length message))
      #f
      message))
  (let loop ([data '()])
    (match (regexp-match #px"^(OK|ERR|#|D)\\s?(.*)?"
                         (read-line (pinentry-stdout pinentry)))
      [(list _ type raw-data)
       (case type
         [("OK") (values #t data (message-result raw-data))]
         [("ERR") (values #f data (message-result raw-data))]
         [("D" "#") (loop (append data `(,raw-data)))])])))


(define (pinentry-connect)
  (let*-values ([(subproc stdout stdin stderr)
                 (subprocess #f #f #f (find-executable-path "pinentry-tty")
                             "--ttyname" (ttyname STDIN-FILENO))]
                [(pinentry) (make-pinentry subproc stdout stdin stderr)]
                [(start-success data message)
                 (pinentry-read-response pinentry)])
    pinentry))


(define (pinentry-disconnect pinentry)
  (subprocess-kill (pinentry-subproc pinentry) #f))


(define (pinentry-exec pinentry command . args)
  (pinentry-write-command pinentry
                          (string-join (append `(,command) args)))
  (pinentry-read-response pinentry))
