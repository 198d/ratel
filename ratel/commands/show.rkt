#lang racket
(require (prefix-in mount: "mount.rkt")
         "../config.rkt")


(provide main)


(define ecryptfs-passphrase (make-parameter #f))


(define (main args)
  (command-line
    #:program "ratel show"
    #:argv args
    #:once-each
    [("--passphrase") passphrase "eCryptfs passphrase to mount with"
                      (ecryptfs-passphrase passphrase)]
    #:args (name filename)

    (let ([mount-config (read-mount-config name)])
      (if (ecryptfs-passphrase)
        (mount:main `("--passphrase" ,(ecryptfs-passphrase) ,name))
        (mount:main `(,name)))
      (with-input-from-file (build-path (get-in mount-config '(mount target))
                                        filename)
                            (lambda ()
                              (copy-port (current-input-port)
                                         (current-output-port)))))))
