#lang racket
(require file/tar
         web-server/http
         "http.rkt"
         "../config.rkt"
         "../passphrase.rkt"
         "../suid-helper.rkt")

(provide get-mounts
         get-files
         get-file
         perform-mount
         perform-umount)


(define (get-mounts request)
  (build-response/json
    200 (map mount-config->jsexpr (read-all-mount-configs))))


(define (perform-mount request mount-name)
  (unless (mount-exists? mount-name)
    (raise-response/raw 404))
  (when (mounted? mount-name)
    (raise-response/raw 204))

  (let*-values ([(passphrase)
                 (bytes->string/utf-8
                   (or (request-post-data/raw request) #""))]
                [(mount-config) (read-mount-config mount-name)]
                [(passphrase-sig _) (generate-passphrase-sig passphrase)])
    (unless (equal? (get-in mount-config '(ecryptfs passphrase-sig))
                    passphrase-sig)
      (raise-response/raw 401))

    (add-passphrase-to-keyring passphrase)

    (if (zero? (suid-mount mount-config))
      (build-response/raw 204)
      (build-response/raw 500))))


(define (perform-umount request mount-name)
  (unless (mount-exists? mount-name)
    (raise-response/raw 404))
  (unless (mounted? mount-name)
    (raise-response/raw 204))

  (let* ([mount-config (read-mount-config mount-name)]
         [umount-result (suid-umount mount-config)])
    (unless (zero? umount-result)
      (raise-response/raw 500))
    (remove-passphrase-from-keyring
      (get-in mount-config '(ecryptfs passphrase-sig)))
    (build-response/raw 204)))


(define (get-files request mount-name)
  (unless (mount-exists? mount-name)
    (raise-response/raw 404))
  (unless (mounted? mount-name)
    (raise-response/raw 409))

  (let ([config (read-mount-config mount-name)])
    (build-response/json
      200
      (let loop ([base (get-in config '(mount target))])
        (map (lambda (dir-entry)
               (let ([comp-path (path->complete-path dir-entry base)]
                     [path-string (path->string dir-entry)])
                 (if (directory-exists? comp-path)
                   `(,path-string ,(loop comp-path))
                   `(,path-string null))))
             (directory-list base))))))


(define (get-file request mount-name path-elements)
  (unless (mount-exists? mount-name)
    (raise-response/raw 404))
  (unless (mounted? mount-name)
    (raise-response/raw 409))

  (let* ([mount-config (read-mount-config mount-name)]
         [relative-file-path (apply build-path path-elements)]
         [absolute-file-path (build-path (get-in mount-config '(mount target))
                                         relative-file-path)])
    (unless (or (file-exists? absolute-file-path)
                (directory-exists? absolute-file-path))
      (raise-response/raw 404))

    (build-response/raw
      200 "application/octet-stream" (list)
      (lambda (output-port)
        (if (directory-exists? absolute-file-path)
          (parameterize ([current-directory
                          (get-in mount-config '(mount target))])
            (tar->output
              (sequence->list (in-directory relative-file-path)) output-port))
          (call-with-input-file
            absolute-file-path (curryr copy-port output-port)))))))
