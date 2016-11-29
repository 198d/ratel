#lang racket
(require net/url
         threading
         racket/runtime-path
         web-server/http
         web-server/dispatch
         web-server/dispatchers/dispatch
         web-server/stuffers/stuffer
         web-server/managers/none
         web-server/servlet/setup
         web-server/private/mime-types
         (rename-in web-server/dispatchers/dispatch-servlets
                    [make make-servlet-dispatcher])
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
    [("api" "mounts" (string-arg))
     #:method "get" get-mount]
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
  (let* ([path-pieces (~> (request-uri req)
                          url->path
                          simplify-path
                          explode-path
                          cdr)]
         [static-path? (or (empty? path-pieces)
                           (equal? (path->string (car path-pieces))
                                   "static"))]
         [asset-path
          (when static-path?
            (apply build-path (append `(,STATIC-ASSETS-DIR)
                                      (if (empty? path-pieces)
                                        '()
                                        (cdr path-pieces)))))])
    (if (and static-path? (or (file-exists? asset-path)
                              (directory-exists? asset-path)))
      ((dispatch-files:make
         #:url->path (lambda (url)
                       (values asset-path (explode-path asset-path)))
         #:path->mime-type (make-path->mime-type MIME-TYPES))
       conn req)
      ((make-servlet-dispatcher
        (lambda (url)
          (make-stateless.servlet
            (current-directory)
            (make-stuffer identity identity)
            (create-none-manager #f)
            servlet-start)))
       conn req))))
