#lang racket
(require "../config.rkt"
         "../system.rkt"
         "../suid-helper.rkt"
         "../passphrase.rkt")


(provide main)


(define ecryptfs-passphrase (make-parameter #f))
(define mount-timeout (make-parameter #f))


(define (main args)
  (command-line
    #:program "ratel mount"
    #:argv args
    #:once-each
    [("--passphrase") passphrase "eCryptfs passphrase to mount with"
                      (ecryptfs-passphrase passphrase)]
    [("--timeout") timeout
                   "Length of time mountpoint will stay mounted after mounting"
                   (mount-timeout (string->number timeout))]
    #:args (name)

    (unless (mount-exists? name)
      (error "Mount does not exist"))

    (unless (mounted? name)
      (unless (ecryptfs-passphrase)
        (ecryptfs-passphrase (read-passphrase name)))

      (let*-values ([(config) (read-mount-config name)]
                    [(timeout) (or (mount-timeout)
                                   (get-in config '(mount timeout)))]
                    [(passphrase-sig _)
                     (generate-passphrase-sig (ecryptfs-passphrase))])
        (if (equal? passphrase-sig
                    (get-in config '(ecryptfs passphrase-sig)))
          (add-passphrase-to-keyring (ecryptfs-passphrase) #:timeout timeout)
          (error "Passphrase signature does not match mount config"))
        (let ([mount-result (suid-mount config)])
        (unless (zero? mount-result)
          (exit mount-result))

        (unless (zero? timeout)
          (daemonize)
          (let loop ([end-time (+ (current-seconds) timeout)])
            (sleep 1)
            (if (and (mounted? name) (< (current-seconds) end-time))
              (loop end-time)
              (when (mounted? name)
                (let-values ([(proc stdout stdin stderr)
                              (subprocess #f #f #f (suid-helper-path)
                                          "umount"
                                          (get-in config '(mount target)))])
                  ; for some reason waiting never returns...
                  (let loop ([status (subprocess-status proc)])
                    (sleep 1)
                    (unless (number? status)
                      (loop (subprocess-status proc))))
                  (close-input-port stdout)
                  (close-output-port stdin)
                  (close-input-port stderr)))))))))))
