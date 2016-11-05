#lang racket
(require ffi/unsafe
         ffi/unsafe/define)


(provide (all-defined-out))


(define SIZEOF-STRUCT-ECRYPTFS-AUTH-TOK 740)

(define ECRYPTFS-SALT-SIZE 8)
(define ECRYPTFS-SIG-SIZE 8)
(define ECRYPTFS-SIG-SIZE-HEX (* ECRYPTFS-SIG-SIZE 2))
(define ECRYPTFS-PASSWORD-SIG-SIZE ECRYPTFS-SIG-SIZE-HEX)
(define ECRYPTFS-MAX-KEY-BYTES 64)


(define-ffi-definer define-libecryptfs (ffi-lib "libecryptfs.so.1"))


(define-libecryptfs generate_passphrase_sig
                    (_fun (passphrase_sig : _bytes) (fekek : _bytes)
                          (salt : _string) (passphrase : _string) -> _int))
(define-libecryptfs generate_payload
                    (_fun (auth_tok : _pointer) (passphrase_sig : _string)
                          (salt : _string)
                          (session_key_encryption_key : _string) -> _int))
