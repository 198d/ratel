#lang racket
(require ffi/unsafe
         ffi/unsafe/define)


(provide (all-defined-out))


(define KEY-SPEC-PROCESS-KEYRING -2)
(define KEY-SPEC-SESSION-KEYRING -3)
(define KEY-SPEC-USER-KEYRING -4)


(define-ffi-definer define-libkeyutils (ffi-lib "libkeyutils.so"))


(define-libkeyutils add_key (_fun (type : _string) (description : _string)
                                  (payload : _pointer) (plen : _int)
                                  (keyring : _int) -> _int))
(define-libkeyutils keyctl_unlink (_fun (key : _int) (keyring : _int) -> _long))
(define-libkeyutils keyctl_search (_fun (keyring : _int) (type : _string)
                                        (description : _string)
                                        (destination : _int) -> _int))
(define-libkeyutils keyctl_set_timeout (_fun (key : _int)
                                             (timeout : _uint) -> _long))
(define-libkeyutils keyctl_join_session_keyring (_fun (name : _string)
                                                      -> _int))
