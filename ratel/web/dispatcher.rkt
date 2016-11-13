#lang racket
(require net/url
         web-server/http
         web-server/dispatch
         web-server/dispatchers/dispatch
         web-server/stuffers/stuffer
         web-server/managers/none
         web-server/servlet/setup
         (rename-in web-server/dispatchers/dispatch-servlets
                    [make make-servlet-dispatcher])
         "http.rkt"
         "actions.rkt")

(provide requests-logger
         dispatcher)


(define requests-logger (make-logger))


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
                                 (lambda (exc) (build-response/raw 500))])
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
  ((make-servlet-dispatcher
    (lambda (url)
      (make-stateless.servlet
        (current-directory)
        (make-stuffer identity identity)
        (create-none-manager #f)
        servlet-start)))
   conn req))

