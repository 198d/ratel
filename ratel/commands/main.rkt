#lang racket
(require "../system.rkt"
         "../config.rkt"
         (prefix-in register: "register.rkt")
         (prefix-in mount: "mount.rkt")
         (prefix-in umount: "umount.rkt"))


(define COMMANDS
  (hash "register" register:main
        "mount" mount:main
        "umount" umount:main))


(command-line
  #:program "ratel"
  #:ps "" "Available commands:" "    register mount umount"
  #:args (command . args)
  (unless (hash-ref COMMANDS command #f)
    (error "Command not implemented. Available commands:"
           (hash-keys COMMANDS)))
  (umask #o77)
  (make-directory* (base-config-path))
  ((hash-ref COMMANDS command) args))
