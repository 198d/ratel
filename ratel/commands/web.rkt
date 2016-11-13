#lang racket
(require web-server/web-server
         "../web/dispatcher.rkt")


(provide main)


(define listen-ip (make-parameter "127.0.0.1"))
(define listen-port (make-parameter 8080))


(define (main args)
  (command-line
    #:program "ratel web"
    #:argv args
    #:once-each
    [("--port") port "TCP Port to listen on"
                (listen-port port)]
    [("--ip-address") ip-address "IP address to listen on"
                      (listen-ip ip-address)]
    #:args ()

    (serve #:dispatch dispatcher
           #:port (listen-port)
           #:listen-ip (listen-ip))

    (thread
      (lambda ()
        (let ([rcvr (make-log-receiver requests-logger 'info)])
          (let loop ()
            (display (vector-ref (sync rcvr) 1) (current-error-port))
            (loop)))))

    (do-not-return)))
