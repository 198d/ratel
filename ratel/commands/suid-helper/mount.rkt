#lang racket
(require ffi/unsafe
         "../../ffi/libc.rkt")


(provide main)


(define (main args)
  (command-line
    #:program "ratel-helper mount"
    #:argv args
    #:args (source target options)

    (unless (zero? (mount source target "ecryptfs"
                          (bitwise-ior MS-NOSUID MS-NODEV)
                          (cast options _string _bytes)))
      (exit (saved-errno)))))
