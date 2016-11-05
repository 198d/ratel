#lang racket
(require ffi/unsafe
         "../../ffi/libc.rkt")


(provide main)


(define (main args)
  (command-line
    #:program "ratel-helper umount"
    #:argv args
    #:args (target)

    (unless (zero? (umount target))
      (exit (saved-errno)))))
