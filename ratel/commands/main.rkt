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
  [("--config-path") config-path
                     "Path to the Ratel config directory"
                     (base-config-path (path->complete-path config-path))]
  [("--suid-helper") suid-helper
                     ("Path to helper program with appropriate permissions "
                      "for priveleged actions")
                     (suid-helper-path (path->complete-path suid-helper))]
  #:ps "" "Available commands:" "    register mount umount web show"
  #:args (command . args)
  (unless (hash-ref COMMANDS command #f)
    (error "Command not implemented. Available commands:"
           (hash-keys COMMANDS)))

  (environment-variables-set!
    (current-environment-variables) #"RATEL_BASE_CONFIG_PATH"
    (string->bytes/utf-8 (path->string (base-config-path))))
  (environment-variables-set!
    (current-environment-variables) #"RATEL_SUID_HELPER_PATH"
    (string->bytes/utf-8 (path->string (suid-helper-path))))

  (umask #o77)
  (make-directory* (base-config-path))
  ((hash-ref COMMANDS command) args))
