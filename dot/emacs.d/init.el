(add-to-list 'load-path (expand-file-name "~/.emacs.d/packages"))


(iswitchb-mode 1)


;;; redo
(require 'redo)
(define-key global-map (kbd "M-_") 'redo)
;;; end redo

;;; color theme
(require 'color-theme)
(setq color-theme-is-global t)
(color-theme-charcoal-black)
;;; end color theme

;;; Emacs 23 font hacking
(setq default-emacs-font "Terminus-13")

(if (>= emacs-major-version 23)
    (progn (set-frame-font default-emacs-font)
           (add-to-list 'default-frame-alist (cons 'font default-emacs-font))))
;;; end Emacs 23 font hacking

;;; wspace
; FIXME: take font-lock off in *Completions* buffers
(require 'show-wspace)
(add-hook 'font-lock-mode-hook 'show-ws-highlight-tabs)
(add-hook 'font-lock-mode-hook 'show-ws-highlight-trailing-whitespace)

; FIXME: compute this color based on the current color-theme
(setq space-color "#562626")
(set-face-background 'show-ws-tab space-color)
(set-face-background 'show-ws-trailing-whitespace space-color)
(set-face-background 'trailing-whitespace space-color)
;;; end wspace

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

;;; generic editing keybindings
(defun scroll-up-one (arg)
  (interactive "p")
  (scroll-up 1))

(defun scroll-down-one (arg) 
  (interactive "p") 
  (scroll-down 1))

(define-key global-map (kbd "M-<up>") 'scroll-down-one)
(define-key global-map (kbd "M-<down>") 'scroll-up-one)
;(define-key global-map (kbd "M-g") 'goto-line)

;;; end generic editing keybindings

;;; git -- I never use this any more since git-cola, but hey!
(require 'git)
;;; end git

;;; java-mode-indent-annotations
(require 'java-mode-indent-annotations)
(add-hook 'java-mode-hook 'java-mode-indent-annotations-setup)
;;; end java-mode-indent-annotations

;;; customize stuff
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(compilation-scroll-output t)
 '(display-buffer-reuse-frames t)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(show-trailing-whitespace t)
 '(transient-mark-mode t)
 '(uniquify-buffer-name-style (quote reverse) nil (uniquify))
 '(uniquify-separator "/"))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
;;; customize stuff

;;; other programming language modes
(require 'css-mode)
(setq auto-mode-alist
      (cons '("\\.css$" . css-mode)
            auto-mode-alist))

;(setq auto-mode-alist
;      (cons '("\\.jxp$" . jsp-mode)
;            auto-mode-alist))


(setq auto-mode-alist
      (cons '("\\.js$" . js2-mode)
            auto-mode-alist))


(defun java-mode-untabify ()
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "[ \t]+$" nil t)
      (delete-region (match-beginning 0) (match-end 0)))
    (goto-char (point-min))
    (if (search-forward "\t" nil t)
	(untabify (1- (point)) (point-max))))
  nil)

(add-hook 'javascript-mode-hook
	  '(lambda ()
	     (make-local-variable 'write-contents-hooks)
;             (add-hook 'write-contents-hooks 'java-mode-untabify)
             ))


(require 'multi-mode)
(defun jsp-mode () (interactive)
  (multi-mode 1
              'html-mode
              '("<%--" indented-text-mode)
              '("{" javascript-mode)
              '("<%@" html-mode)
              '("<%=" html-mode)
              '("<%" java-mode)
              '("%>" html-mode)
              )
  )

(add-hook 'jsp-mode-hook
	  '(lambda ()
	     (make-local-variable 'write-contents-hooks)
;	     (add-hook 'write-contents-hooks 'java-mode-untabify)
             ))

;;; jxp-mode stuff.
;;;
;;; This is a symlink to a file that might get updated and on some
;;; machines doesn't even exist, so we wrap it in a condition-case (in
;;; case it doesn't exist here).
(condition-case 'jxp-error
    (progn (require 'jxp-mode)
           (require 'mmm-mode)

           (setq mmm-global-mode 'maybe)
           (mmm-add-mode-ext-class 'html-mode "\\.jxp\\'" 'html-jxp)
           (mmm-add-mode-ext-class 'html-mode "\\.jxp\\'" 'html-js)
           (mmm-add-classes
            '((html-jxp
               :submode jxp-mode
               :face mmm-declaration-submode-face
               :front "<%=?"
               :back "%>"
               :include-front t
               :include-back t
               )))
           (mmm-add-classes
            '((html-js
               :submode jxp-mode
               :face mmm-output-submode-face
               :front "<script[^>]*>"
               :back "</script>"
               :include-front t
               :include-back t
               )))
           (autoload 'jxp-mode "jxp-mode" "JXP editing mode" t)
           (add-to-list 'auto-mode-alist '("\\.jxp\\'" . html-mode))
           ;; mmm-mode conveniently displays jxp code as white-on-white unless the highlight level is set to 0
           (setq mmm-submode-decoration-level 0))
  (error (message "Failed to load jxp mode: %s" jxp-error)))
; FIXME: fall back on JSP mode?
;;; end programming language modes



