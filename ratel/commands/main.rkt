#lang racket
(require racket/os
         ffi/unsafe
         "../system.rkt"
         "../config.rkt"
         "../ffi/libc.rkt"
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


(define ratel-unshare (make-parameter #f))


(command-line
  #:program "ratel"
  #:once-each
  [("--unshare") ("Relaunches command in a new mount namespace with a new "
                  "session keyring and unmounts all currently mounted "
                  "filesystems")
                (ratel-unshare #t)]
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

  (when (and (ratel-unshare) (not (getenv "RATEL_UNSHARING")))
    (let* ([cmdline (file->string (format "/proc/~a/cmdline" (getpid)))]
           [exe (resolve-path (format "/proc/~a/exe" (getpid)))]
           [parsed-cmdline (string-split cmdline (bytes->string/utf-8 #"\0"))])
      (execvp (suid-helper-path) (append `(,(suid-helper-path) "unshare")
                                         `(,exe) parsed-cmdline '(#f)))
      (error "could not execute unshare command" (saved-errno))))

  ((hash-ref COMMANDS command) args))
