#lang racket
(require json
         threading
         "system.rkt")


(provide base-config-path
         suid-helper-path
         file->jsexpr
         jsexpr->file
         mount-config->jsexpr
         jsexpr->mount-config
         read-mount-config
         read-all-mount-configs
         write-mount-config
         mount-exists?
         mounted?
         member-in
         get-in
         update-in)


(define base-config-path
  (make-parameter (or (getenv "RATEL_BASE_CONFIG_PATH")
                      (build-path (find-system-path 'home-dir) ".ratel"))))
(define suid-helper-path
  (make-parameter (or (getenv "RATEL_SUID_HELPER_PATH")
                      (find-executable-path "ratel-helper"))))


(define (file->jsexpr path)
  (with-input-from-file path read-json))


(define (jsexpr->file value path)
  (with-output-to-file path (lambda () (write-json value))))


(define (mount-config-path name)
  (build-path (base-config-path) (string-append name ".mount")))


(define (mount-exists? name)
  (file-exists? (mount-config-path name)))


(define (mounted? name-or-config)
  (match name-or-config
    [(? dict?) (mount-point? (get-in name-or-config '(mount source))
                             (get-in name-or-config '(mount target)))]
    [(? string?) (mounted? (read-mount-config name-or-config))]))


(define (mount-point? source target)
  (list? (memf (lambda (system-mount)
                 (and (equal? (list-ref system-mount 2) "ecryptfs")
                      (equal? (list-ref system-mount 0) source)
                      (equal? (list-ref system-mount 1) target)))
               (read-system-mounts))))


(define (jsexpr->mount-config jsexpr)
  (~> jsexpr
      (update-in '(mount source) path->directory-path)
      (update-in '(mount target) path->directory-path)))


(define (mount-config->jsexpr config)
  (let ([directory-updater (compose path->string path->directory-path)])
    (~> config
        (update-in '(mount source) directory-updater)
        (update-in '(mount target) directory-updater))))


(define (read-all-mount-configs)
  (for/list ([path (directory-list (base-config-path) #:build? #t)]
             #:when (regexp-match #rx".mount$" path))
    (jsexpr->mount-config (file->jsexpr path))))


(define (read-mount-config name)
  (jsexpr->mount-config (file->jsexpr (mount-config-path name))))


(define (write-mount-config config)
  (jsexpr->file (mount-config->jsexpr config)
                (mount-config-path (get-in config '(name)))))


(define (member-in dict-value keys)
  (if (and (empty? (cdr keys)) (dict-has-key? dict-value (car keys)))
    dict-value
    (if (not (dict-has-key? dict-value (car keys)))
      #f
      (member-in (dict-ref dict-value (car keys)) (cdr keys)))))


(define (get-in dict-value keys
                [failure-result (lambda ()
                                  (error "No value found for keys"))])
  (dict-ref (or (member-in dict-value keys) (hash))
            (last keys) failure-result))


(define (update-in dict-value keys updater
                   [failure-result (lambda ()
                                     (error "No value found for keys"))])
  (if (empty? (cdr keys))
    (dict-update dict-value (car keys) updater failure-result)
    (let ([update-result
           (update-in
             (dict-ref dict-value (car keys) failure-result)
             (cdr keys)
             updater
             failure-result)])
      (dict-update dict-value
                   (car keys)
                   (lambda (value) update-result)
                   failure-result))))

