#lang racket
(require (prefix-in mount: "mount.rkt")
         "../config.rkt")


(provide main)


(define (main args)
  (command-line
    #:program "ratel show"
    #:argv args
    #:args (name filename)

    (let ([mount-config (read-mount-config name)])
      (mount:main `(,name))
      (with-input-from-file (build-path (get-in mount-config '(mount target))
                                        filename)
                            (lambda ()
                              (copy-port (current-input-port)
                                         (current-output-port)))))))
