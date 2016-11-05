#lang racket
(require "ffi/libc.rkt")


(provide daemonize
         umask
         read-system-mounts)


(define (daemonize)
  (daemon #f #f))


(define (read-system-mounts)
  (map (lambda (line)
         (let ([parts (string-split line)])
           (list (path->directory-path (list-ref parts 0))
                 (path->directory-path (list-ref parts 1))
                 (list-ref parts 2)
                 (list-ref parts 3)
                 (string->number (list-ref parts 3))
                 (string->number (list-ref parts 4)))))
           (file->lines "/proc/mounts")))
