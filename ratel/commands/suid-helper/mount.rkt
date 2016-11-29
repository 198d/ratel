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
                    (and (equal? (get-in config '(mount target))
                                 (string->path target))
                         (equal? (get-in config '(mount source))
                                 (string->path source))))
                  (read-all-mount-configs))
      (error "No mount matching the source and target is registered"))

    (unless (zero? (mount source target "ecryptfs"
                          (bitwise-ior MS-NOSUID MS-NODEV)
                          (cast options _string _bytes)))
      (exit (saved-errno)))))
