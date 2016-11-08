#lang racket
(require "../config.rkt"
         "../system.rkt"
         "../passphrase.rkt")


(provide main)


(define ecryptfs-passphrase (make-parameter #f))
(define mount-timeout (make-parameter #f))


(define (suid-mount source target cipher key-bytes sig fnek-sig)
  (system*/exit-code
    (suid-helper-path) "mount" source target
    (format
      (string-append
        "ecryptfs_check_dev_ruid,ecryptfs_cipher=~a,"
        "ecryptfs_key_bytes=~a,ecryptfs_unlink_sigs,"
        "ecryptfs_sig=~a,ecryptfs_fnek_sig=~a")
      cipher key-bytes sig fnek-sig)))


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
    [("--suid-helper") suid-helper
                       "Path to helper program with permissions to mount"
                       (suid-helper-path (path->complete-path suid-helper))]
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
        (let ([mount-result (suid-mount (get-in config '(mount source))
                                        (get-in config '(mount target))
                                        (get-in config '(ecryptfs cipher))
                                        (get-in config '(ecryptfs key-bytes))
                                        passphrase-sig passphrase-sig)])
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
