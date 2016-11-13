#lang racket
(require "../config.rkt"
         "../suid-helper.rkt"
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
             [umount-result (suid-umount config)])
        (unless (zero? umount-result)
          (exit umount-result))
        (remove-passphrase-from-keyring
          (get-in config '(ecryptfs passphrase-sig)))))))
