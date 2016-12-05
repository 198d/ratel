#lang racket
(require ffi/unsafe
         "../../config.rkt"
         "../../ffi/libc.rkt"
         "../../ffi/libkeyutils.rkt")


(provide main)


(define (main args)
  (command-line
    #:program "ratel-helper unshare"
    #:argv args
    #:args (path . argv)

    (unshare CLONE-NEWNS)
    (mount #f "/" #f (bitwise-ior MS-PRIVATE MS-REC) #f)

    (for ([mount-config (in-list (read-all-mount-configs))])
      (umount (get-in mount-config '(mount target))))

    (setgid (getgid))
    (setuid (getuid))

    (keyctl_join_session_keyring #f)

    (environment-variables-set!
      (current-environment-variables) #"RATEL_DEFAULT_KEYRING"
      (string->bytes/utf-8 "SESSION"))
    (environment-variables-set!
      (current-environment-variables) #"RATEL_UNSHARING"
      (string->bytes/utf-8 "true"))

    (execvp path (append argv '(#f)))))
