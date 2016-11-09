#lang racket
(require ffi/unsafe
         "../../config.rkt"
         "../../ffi/libc.rkt")


(provide main)


(define (main args)
  (command-line
    #:program "ratel-helper mount"
    #:argv args
    #:args (source target options)

    (unless (memf (lambda (config)
                    (and (equal? (get-in config '(mount target)) target)
                         (equal? (get-in config '(mount source)) source)))
                  (read-all-mount-configs))
      (error "No mount matching the source and target is registered"))

    (unless (zero? (mount source target "ecryptfs"
                          (bitwise-ior MS-NOSUID MS-NODEV)
                          (cast options _string _bytes)))
      (exit (saved-errno)))))
