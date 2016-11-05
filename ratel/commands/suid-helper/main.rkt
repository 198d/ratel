#lang racket
(require (prefix-in mount: "mount.rkt")
         (prefix-in umount: "umount.rkt"))


(define COMMANDS
  (hash "mount" mount:main
        "umount" umount:main))


(command-line
  #:program "ratel-helper"
  #:ps "" "Available commands:" "    mount umount"
  #:args (command . args)
  (unless (hash-ref COMMANDS command #f)
    (error "Command not implemented. Available commands:"
           (hash-keys COMMANDS)))
  ((hash-ref COMMANDS command) args))
