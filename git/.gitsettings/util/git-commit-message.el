(require 'package)
(setq package-enable-at-startup nil)
(package-initialize)

;; mac laptop stuff
(if (eq system-type 'darwin)
    (progn (setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))
	   (setenv "PATH" (concat "/usr/local/ossh/bin:/usr/local/krb5/bin:" (getenv "PATH"))) ;DoD
	   (osx-clipboard-mode +1)
	   (osx-trash-setup)
	   (setq delete-by-moving-to-trash t)
	   )
  )

;; Copy environment variables over if on Mac window system
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

; Display (or don't display) trailing whitespace characters using an
; unusual background color so they are visible.
(setq-default show-trailing-whitespace t)
(setq-default indicate-empty-lines t)

; Make the Control-n and Control-p keys (and the down arrow and up
; arrow keys) scroll the current window one line at a time instead
; of one-half screen at a time.
(setq scroll-step 1)

;; Show column numbers too
(column-number-mode 1)

;; Turn on spell checking on the fly
(flyspell-mode)

;; Wrap text at 72
(auto-fill-mode 1)
(setq fill-column 72)

;; Give IDO mode a shot
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)
(setq ido-use-filename-at-point 'guess)
(setq ido-file-extensions-order '(".F90" ".f90" ".pbs" ".inp" ".sh" ".el" ".py" ".cmd" ".txt"))
(setq ido-create-new-buffer 'prompt)

;; auto completions
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(ac-config-default)
(global-auto-complete-mode t)
(ac-set-trigger-key "TAB")
(ac-set-trigger-key "<tab>")

;; better performance, maybe...
(setq redisplay-dont-pause t)
;http://www.masteringemacs.org/articles/2011/10/02/improving-performance-emacs-display-engine/

;; enable visual feedback on selections
(setq transient-mark-mode t)

;; make backups of commit messages
(setq make-backup-files 'non-nil)
(setq
   backup-by-copying t       ; don't clobber symlinks
   backup-directory-alist
    '(("." . "~/.saves"))    ; don't litter my fs tree
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 3
   version-control t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(git-commit-confirm-commit t)
 '(git-commit-mode-hook
   (quote
    (turn-on-auto-fill flyspell-mode)))
 )
