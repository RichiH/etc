(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(ansi-color-for-comint-mode-on)

(xterm-mouse-mode t)

;; Revert automatically. Only reverts nonmodified files. This might cause
;; a lot of network traffic when used with tramp?
(global-auto-revert-mode 1)

;; I should probably be able to make this introspect or something
(let ((tmp "~/.emacs.d/cache/"))
  (custom-set-variables
   (list 'oddmuse-directory (concat tmp "oddmuse"))
   (list 'save-place-file (concat tmp "places"))
   (list 'tramp-persistency-file-name (concat tmp "tramp"))
   (list 'ido-save-directory-list-file (concat tmp "ido.last"))
   (list 'bookmark-default-file (concat tmp "emacs.bmk"))
   (list 'recentf-save-file (concat tmp "recentf"))))

;;; redo: There may be a better way to do this, but my tiny brain can
;;; only handle so much.
(require 'redo)
(define-key global-map (kbd "M-_") 'redo)
;;; end redo

(require 'ido)
(ido-mode 1)

;; Ido: don't ignore project.git, but ignore .git itself.
(let ((vcs-extensions '(".svn/" ".hg/" ".git/" ".bzr/")))
  ;; remove .git/ from completion-ignored-extensions, because it matches endings
  (mapc '(lambda (extension)
           (setq completion-ignored-extensions
                 (remove extension completion-ignored-extensions)))
        vcs-extensions)
  (setq ido-ignore-files
        (append
         ;; But do ignore files that are just .git, .hg, .svn, etc.
         ;; generate regexes that are ^.git, etc.
         (mapcar '(lambda (arg) (concat "^" arg)) vcs-extensions)
         ido-ignore-files)))
;;;

;;; magit
; Weirdness on OS X -- PATH doesn't get set or something when running emacs
(if (file-exists-p "/usr/local/git/bin/git")
    (setq magit-git-executable "/usr/local/git/bin/git"))
;;; end magit

;;; wspace -- both displaying, and editing
(require 'ethan-wspace)
(global-ethan-wspace-mode 1)

;;; color theme
(require 'color-theme)
(setq color-theme-is-global t)
(if (functionp 'color-theme-initialize)
    (color-theme-initialize))
(color-theme-charcoal-black)
;;; end color theme

;;; abbrev
(setq abbrev-file-name (emacs-d "abbrev_defs.el"))
(read-abbrev-file abbrev-file-name t)
(setq abbrev-mode t)   ; not really sure about this... RST has some abbrevs too

;;; elide-head
(require 'elide-head)

(setq elide-head-headers-to-hide
      (append
       '(("Copyright (C) 2008 10gen Inc\\." . "If not, see <http")   ; AGPL
         ("Copyright (C) 2008 10gen Inc\\." . "under the License\\.") ; APL
         )
       elide-head-headers-to-hide))

(add-hook 'find-file-hook 'elide-head)
;;; end elide-head

;;; desktop-mode config
; I don't expect to ever use it, but it's nice to
; have.  Save session with desktop-save, then read using desktop-read.
; desktop-save doesn't overwrite it's previous save.. not sure why or
; how to fix. Maybe desktop-save-mode?
(set-default 'desktop-path (list (expand-file-name "~/.emacs.d/")))
;;; end desktop-mode

;; Some modes
(setq auto-mode-alist
      (append
       '(
         ("writing/"             . text-mode)
         ("\\.mdwn$"             . mdwn-mode)
         ) auto-mode-alist))
;; text mode
(add-to-list 'text-mode-hook 'turn-on-visual-line-mode)

(provide 'ethan-misc)
