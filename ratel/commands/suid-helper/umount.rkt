#lang racket
(require ffi/unsafe
         "../../config.rkt"
         "../../ffi/libc.rkt")


(provide main)


(define (main args)
  (command-line
    #:program "ratel-helper umount"
    #:argv args
    #:args (target)

    (unless (memf (lambda (config)
                    (equal? (get-in config '(mount target)) target))
                  (read-all-mount-configs))
      (error "No mount matching the target is registered"))

    (unless (zero? (umount target))
      (exit (saved-errno)))))
