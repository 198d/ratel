#lang racket
(require openssl
         web-server/web-server
         web-server/private/dispatch-server-sig
         "../web/dispatcher.rkt")


(provide main)


(define listen-ip (make-parameter "127.0.0.1"))
(define listen-port (make-parameter 8080))
(define ssl-server-cert (make-parameter #f))
(define ssl-server-key (make-parameter #f))
(define ssl-client-cert (make-parameter #f))


(define (make-ssl-connect@ server-cert server-key [client-cert #f])
  (let ([ssl-context (ssl-make-server-context)])
    (ssl-load-certificate-chain! ssl-context server-cert)
    (ssl-load-private-key! ssl-context server-key)

    (when client-cert
      (ssl-load-verify-source! ssl-context client-cert)
      (ssl-set-verify! ssl-context #t))

    (define-unit ssl:dispatch-server-connect@
      (import) (export dispatch-server-connect^)
      (define (port->real-ports ip op)
        (ports->ssl-ports	ip op
                          #:mode 'accept
                          #:context ssl-context)))

    ssl:dispatch-server-connect@))


(define (main args)
  (command-line
    #:program "ratel web"
    #:argv args
    #:once-each
    [("--port") port "TCP Port to listen on"
                (listen-port port)]
    [("--ip-address") ip-address "IP address to listen on"
                      (listen-ip ip-address)]
    [("--ssl-server-cert") server-cert "Path to server certificate file"
                           (ssl-server-cert server-cert)]
    [("--ssl-server-key") server-key "Path to server private key file"
                          (ssl-server-key server-key)]
    [("--ssl-client-cert") client-cert "Path to client CA certificate file"
                           (ssl-client-cert client-cert)]
    #:args ()

    (when (xor (ssl-server-cert) (ssl-server-key))
      (error "--ssl-server-cert and --ssl-server-key must both be provided"))

    (when (and (ssl-client-cert)
               (not (and (ssl-server-key)
                         (ssl-server-cert))))
      (error
        (string-append "--ssl-server-cert and --ssl-server-key must both "
                       "be provided wtih --ssl-client-cert")))

    (if (and (ssl-server-cert) (ssl-server-key))
      (serve #:dispatch dispatcher
             #:port (listen-port)
             #:listen-ip (listen-ip)
             #:dispatch-server-connect@ (make-ssl-connect@
                                          (ssl-server-cert)
                                          (ssl-server-key)
                                          (ssl-client-cert)))
      (serve #:dispatch dispatcher
             #:port (listen-port)
             #:listen-ip (listen-ip)))

    (thread
      (lambda ()
        (let ([rcvr (make-log-receiver requests-logger 'info)])
          (let loop ()
            (display (vector-ref (sync rcvr) 1) (current-error-port))
            (loop)))))

    (do-not-return)))
