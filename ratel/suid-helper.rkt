#lang racket
(require "config.rkt")


(provide suid-mount
         suid-umount)


(define (suid-mount mount-config)
  (system*/exit-code
    (suid-helper-path) "mount" (get-in mount-config '(mount source))
    (get-in mount-config '(mount target))
    (format
      (string-append
        "ecryptfs_check_dev_ruid,ecryptfs_cipher=~a,"
        "ecryptfs_key_bytes=~a,ecryptfs_unlink_sigs,"
        "ecryptfs_sig=~a,ecryptfs_fnek_sig=~a")
      (get-in mount-config '(ecryptfs cipher))
      (get-in mount-config '(ecryptfs key-bytes))
      (get-in mount-config '(ecryptfs passphrase-sig))
      (get-in mount-config '(ecryptfs passphrase-sig)))))


(define (suid-umount mount-config)
  (system*/exit-code
    (suid-helper-path) "umount" (get-in mount-config '(mount target))))
