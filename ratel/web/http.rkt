#lang racket
(require json
         web-server/http)


(provide build-response/raw
         build-response/json
         raise-response/raw)


(define (response-code->message code)
  (hash-ref (hash 200 #"OK"
                  204 #"No Content"
                  401 #"Not Authorized"
                  404 #"Not Found"
                  409 #"Conflict"
                  500 #"Internal Server Error"
                  501 #"Not Implemented")
            code))


(define (build-response/raw code [content-type "text/plain"] [headers (list)]
                            [body (list)])
  ((if (list? body)
     response/full
     response)
    code (response-code->message code)
    (current-seconds)
    (string->bytes/utf-8 (format "~a; charset=utf-8" content-type))
    headers body))


(define (raise-response/raw . args)
  (raise (apply build-response/raw args)))


(define (build-response/json code jsexpr)
  (build-response/raw
    code "application/json" (list)
    (list (string->bytes/utf-8
            (jsexpr->string jsexpr)))))
