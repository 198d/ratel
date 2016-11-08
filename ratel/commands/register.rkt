#lang racket
(require "../config.rkt"
         "../passphrase.rkt")
(provide main)


(define ecryptfs-cipher (make-parameter "aes"))
(define ecryptfs-key-bytes (make-parameter "32"))
(define ecryptfs-passphrase (make-parameter #f))
(define mount-timeout (make-parameter 0))
(define mount-target (make-parameter #f))
(define create-directories? (make-parameter #f))


(define (main args)
  (command-line
    #:program "ratel register"
    #:argv args
    #:once-each
    [("--cipher") cipher "Cipher to use on the eCryptfs volume"
                  (ecryptfs-cipher cipher)]
    [("--key-bytes") key-bytes "Key size (in bytes) for the eCryptfs volume"
                     (ecryptfs-key-bytes key-bytes)]
    [("--timeout") timeout
                   "Length of time mountpoint will stay mounted after mounting"
                   (mount-timeout (string->number timeout))]
    [("--passphrase") passphrase "eCryptfs passphrase to mount with"
                      (ecryptfs-passphrase passphrase)]
    [("--mount-target") target "Target directory to mount volume at"
                        (mount-target target)]
    [("--create") "Create source and target directories if they do not exist"
                  (create-directories? #t)]
    #:args (name source)

    (when (mount-exists? name)
      (error "Mount already exists"))

    (unless (ecryptfs-passphrase)
      (ecryptfs-passphrase (read-passphrase name)))

    (let-values ([(passphrase-sig _)
                  (generate-passphrase-sig (ecryptfs-passphrase))])
      (when (create-directories?)
        (make-directory* (path->complete-path source))
        (when (mount-target)
          (make-directory* (path->complete-path (mount-target)))))

      (write-mount-config
        (hash 'name name
              'ecryptfs (hash 'cipher (ecryptfs-cipher)
                              'key-bytes (ecryptfs-key-bytes)
                              'passphrase-sig passphrase-sig)
              'mount (hash 'source source
                           'target (or (mount-target) source)
                           'timeout (mount-timeout)))))))
