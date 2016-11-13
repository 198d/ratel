#lang racket
(require "../system.rkt"
         "../config.rkt"
         (prefix-in register: "register.rkt")
         (prefix-in mount: "mount.rkt")
         (prefix-in umount: "umount.rkt")
         (prefix-in web: "web.rkt")
         (prefix-in show: "show.rkt"))


(define COMMANDS
  (hash "register" register:main
        "mount" mount:main
        "umount" umount:main
        "web" web:main
        "show" show:main))


(command-line
  #:program "ratel"
  #:once-each
  [("--suid-helper") suid-helper
                     ("Path to helper program with appropriate permissions "
                      "for priveleged actions")
                     (suid-helper-path (path->complete-path suid-helper))]
  #:ps "" "Available commands:" "    register mount umount web show"
  #:args (command . args)
  (unless (hash-ref COMMANDS command #f)
    (error "Command not implemented. Available commands:"
           (hash-keys COMMANDS)))
  (umask #o77)
  (make-directory* (base-config-path))
  ((hash-ref COMMANDS command) args))
