#lang racket
(require "../config.rkt"
         "../passphrase.rkt")


(provide main)



(define (main args)
  (command-line
    #:program "ratel umount"
    #:argv args
    #:args (name)

    (unless (mount-exists? name)
      (error "Mount does not exist"))

    (when (mounted? name)
      (let* ([config (read-mount-config name)]
             [umount-result (system*/exit-code
                              (suid-helper-path)
                              "umount"
                              (get-in config '(mount target)))])
        (unless (zero? umount-result)
          (exit umount-result))
        (remove-passphrase-from-keyring
          (get-in config '(ecryptfs passphrase-sig)))))))
