;; Organize all the paths that emacs packages use to crap up .emacs.d
;; I should probably be able to make this introspect or something
(let ((tmp "~/.emacs.d/cache/"))
  (setq
   oddmuse-directory (concat tmp "oddmuse")
   save-place-file (concat tmp "places")
   tramp-persistency-file-name (concat tmp "tramp")
   ido-save-directory-list-file (concat tmp "ido.last")
   bookmark-default-file (concat tmp "emacs.bmk")
   recentf-save-file (concat tmp "recentf")
   auto-save-list-file-prefix (concat tmp "auto-save-list/saves-")
   *cheat-directory* (concat tmp "cheat")
   *cheat-sheets-cache-file* (concat tmp "cheat/sheets")))

;; overrride the default function....
(defun emacs-session-filename (SESSION-ID)
  (concat "~/.emacs.d/cache/session." SESSION-ID))

;; Don't clutter up directories with files~
(setq backup-directory-alist `(("." . ,(expand-file-name
                                        (emacs-d "backups")))))
(setq tramp-backup-directory-alist backup-directory-alist)
