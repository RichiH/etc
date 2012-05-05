;;; esvn-mode.el --- like maniac-mode, but for committing

;; Copyright (C) 2006-2012 Ethan Glasser-Camp
;;
;; This package is released under a BSD license.

;; Author: Ethan Glasser-Camp <ethan@betacantrips.com>
;; Keywords: automatic, commit, VCS
;; Version: 0.1.3

;;; Commentary:
;; The intersection of creative writing and version control is a weird
;; space where programmers try to write tools for
;; authors. Flashbake[1] is a good example of this kind of tool;
;; instead of providing a simplified interface to a version control
;; system, it automatically commits every few minutes, with relatively
;; content-free commit messages based on whatever context the software
;; notices. esvn is also in this tradition, but in a more ham-fisted
;; way.
;;
;; esvn is a minor mode that also helps to seamlessly and
;; semi-automatically commit whatever writing you're working on. By
;; default, it provides one function, esvn-commit, which prompts for
;; a commit message before committing just the file you're working
;; on. If run with a prefix argument, it just commits.
;;
;; You can bind a function like esvn-save-or-autocommit to C-x C-s, to
;; ensure that you're always committing whatever you've been
;; writing.
;;
;; [1] http://bitbucketlabs.net/flashbake/

;; FIXME: switching major modes turns this off??

(defgroup esvn-group nil "Group for esvn customization stuff."
  :version "21.4.20" :prefix 'esvn-)

(defcustom esvn-default-commit-message ""
  "*Default commit message."
  :type '(string) :group 'esvn-group)
(defcustom esvn-default-add-message nil
  "*Default commit message if adding a file.

If nil, esvn will try esvn-default-commit-message."
  :type '(string) :group 'esvn-group)
(defcustom esvn-default-autocommit-message nil
  "*Default commit message if autocommitting (committing without user intervention).

If nil, esvn will try esvn-default-commit-message."
  :type '(string) :group 'esvn-group)
(defcustom esvn-default-autocommit-add-message nil
  "*Default commit message if adding a file while autocommitting.

If nil, esvn will try esvn-default-add-message, esvn-default-autocommit-message, and
esvn-default-commit-message in that order."
  :type '(string) :group 'esvn-group)

(defcustom esvn-svn-command "svn"
  "*Command name to use when calling the version control system."
  :type '(string) :group 'esvn-group)

;;;###autoload
(define-minor-mode esvn-mode
  "Provide a command to semi-automatically commit whatever you're working on.

This might be useful for your creative writing projects that you're working on in emacs."
  nil " E"
  '(([?\C-c ?\C-c] . esvn-commit))

  (if esvn-mode
      (add-hook 'find-file-not-found-hooks 'esvn-new-file)
    (remove-hook 'find-file-not-found-hooks 'esvn-new-file)))

(defvar esvn-buffer-file-status nil
  "Status of file associated with a buffer.

This can be the symbol :new, which means \"not in SVN (needs to be
added)\"; the symbol :committed, which means \"in SVN (doesn't need
to be added)\"; or nil, which means \"unknown\".")
(make-variable-buffer-local 'esvn-buffer-file-status)

(setq esvn-error-types
      '((esvn-stat-failed . "svn stat failed")
        (esvn-bad-commit-message . "Bad commit message")))

(mapcar (lambda (elem) (set (car elem) (cdr elem)))
        esvn-error-types)
(defun esvn-error (symbol string)
  (error "%s: %s" (eval symbol) string))

(defun esvn-new-file ()
  "Function to mark a new file as \"new\", for later adding."
  (setq esvn-buffer-file-status :new))

(defun esvn-default-message (adding autocommit)
  "Get the default message to commit this file."
  ;; Take the most specific of: autocommit-add-message, add-message,
  ;; autocommit-message, or the default message.
  (or
   (when (and adding autocommit) esvn-default-autocommit-add-message)
   (when adding (cons esvn-default-add-message choices))
   (when autocommit esvn-default-autocommit-message)
   esvn-default-commit-message))

(defun esvn-get-commit-message (adding autocommit)
  "Get a commit message from the user.

If adding a file for the first time, use esvn-default-add-message
as the default. If not adding, or if that variable is empty,
use esvn-default-commit-message."
  (let* ((defmsg (esvn-default-message adding autocommit))
         (prompt
          (if (not (string= defmsg ""))
              (format "Commit message (default %s):" defmsg)
            "Commit message:"))
         (response (read-from-minibuffer (concat prompt " "))))
    (if (string= response "")
        defmsg
      response)))

(defun esvn-execvp (&rest args)
  "Simulate C's execvp() function.

Quote each argument seperately, join with spaces and call shell-command-to-string to run in a shell."
  (let ((cmd (mapconcat 'shell-quote-argument args " ")))
    (shell-command-to-string cmd)))

(defun esvn-get-buffer-file-status ()
  "Find out whether the file corresponding to the buffer is in SVN.

On success, returns :new or :committed."
  (let* ((svnout (esvn-execvp esvn-svn-command "stat" buffer-file-name))
         (fields (split-string svnout)))
    (when (< (length fields) 1) ; no stat output -- file not there?
      (esvn-error 'esvn-stat-failed "file not there"))

    (let ((status (car fields))
          (file (car (cdr fields))))

      (cond ((string= status "?") :new)
            ((string= status "A") :committed) ; no need to add
            ((string= status "M") :committed)))))

(defun last-line (string)
  (car (last (split-string string "\n" t))))

(defun esvn-commit (autocommit)
  "Commit the local buffer.

If autocommit is true, automatically commit using the default message (either
esvn-default-add-message or esvn-default-commit-message)."
  (interactive "P")
  (save-buffer)
  (when (not esvn-buffer-file-status)
    (setq esvn-buffer-file-status (esvn-get-buffer-file-status)))
  (let ((adding (eq esvn-buffer-file-status :new)))
    (when adding
      (message (esvn-execvp esvn-svn-command "add" buffer-file-name)))
    (let ((response (if autocommit (esvn-default-message adding autocommit)
                      (esvn-get-commit-message adding autocommit))))
      (when (string= response "")
        (esvn-error 'esvn-bad-commit-message "No message given"))
      (let ((output (esvn-execvp esvn-svn-command "commit" "-m" response buffer-file-name)))
        (if (= (length output) 0)
            (message "Committed %s" buffer-file-name)
          (message (last-line output))))
      (setq esvn-buffer-file-status :committed))))

(defun esvn-save-or-autocommit (save)
  "Save or autocommit, based on prefix arg. Prefix arg means save; otherwise, autocommit."
  (interactive "P")
  (if save (save-buffer) (esvn-commit t)))

(provide 'esvn)
