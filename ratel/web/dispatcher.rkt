#lang racket
(require net/url
         racket/runtime-path
         web-server/http
         web-server/dispatch
         web-server/dispatchers/dispatch
         web-server/stuffers/stuffer
         web-server/managers/none
         web-server/servlet/setup
         web-server/private/mime-types
         web-server/dispatchers/filesystem-map
         (prefix-in dispatch-servlets:
                    web-server/dispatchers/dispatch-servlets)
         (prefix-in dispatch-files: web-server/dispatchers/dispatch-files)
         "http.rkt"
         "actions.rkt")

(provide requests-logger
         dispatcher)


(define requests-logger (make-logger))


(define-runtime-path STATIC-ASSETS-DIR "frontend/build")
(define-runtime-path
  MIME-TYPES
  (collection-file-path "default-web-root/mime.types" "web-server"))


(define-values (url-dispatcher make-url)
  (dispatch-rules
    [("api" "mounts")
     #:method "get" get-mounts]
    [("api" "mounts" (string-arg) "mount")
     #:method "post" perform-mount]
    [("api" "mounts" (string-arg) "umount")
     #:method "post" perform-umount]
    [("api" "mounts" (string-arg) "files")
     #:method "get" get-files]
    [("files" (string-arg) (string-arg) ...)
     #:method "get" get-file]))


(define (servlet-start req)
  (parameterize ([current-logger requests-logger])
    (let ([resp (with-handlers ([response?
                                 (lambda (resp) resp)]
                                [exn:dispatcher?
                                 (lambda (exc) (build-response/raw 404))]
                                [exn:fail?
                                 (lambda (exc) (displayln exc)
                                   (build-response/raw 500))])
                  (url-dispatcher req))])
      (log-info "~s\n" `((time ,(current-seconds))
                         (client-ip ,(request-client-ip req))
                         (method ,(request-method req))
                         (headers ,(request-headers/raw req))
                         (uri ,(url->string (request-uri req)))
                         (response ,(format "~a ~a" (response-code resp)
                                            (response-message resp)))))
      resp)))


(define (dispatcher conn req)
  (let loop ([dispatchers
              `(,(dispatch-files:make
                  #:url->path (make-url->path STATIC-ASSETS-DIR)
                  #:path->mime-type (make-path->mime-type MIME-TYPES))
                ,(dispatch-servlets:make
                  (lambda (url)
                    (make-stateless.servlet
                      (current-directory)
                      (make-stuffer identity identity)
                      (create-none-manager #f)
                      servlet-start))))])
    (with-handlers ([exn:dispatcher? (lambda (exc) (loop (cdr dispatchers)))])
      ((car dispatchers) conn req))))
