;; Uncomment to enable debugging
(setq debug-on-error t) ; set this to get stack traces on errors

;; Use use-package to create portable emacs-config
;; bootstrap emacs setup from package managers
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))
(package-initialize)

(setq use-package-verbose t) ; verbose init debug & profiling

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))
(require 'diminish)
(require 'bind-key)

(setq use-package-verbose t) ; verbose init debug & profiling

;; Use the zenburn theme, but ONLY if we have a window system
(setq custom-safe-themes
      (quote
       ("67e998c3c23fe24ed0fb92b9de75011b92f35d3e89344157ae0d544d50a63a72" default)))
(use-package zenburn-theme
  :if window-system
  :ensure t
  :config
  (load-theme 'zenburn)
  )

;; Starts the Emacs server when window system
(use-package edit-server
  :if window-system
  :ensure t
  :init
  (add-hook 'after-init-hook 'server-start t)
  (add-hook 'after-init-hook 'edit-server-start t))

;; Use shell/env path for exec-path
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :ensure t
  :config
  (exec-path-from-shell-initialize))

;; Install macOS specific helper packages
(use-package osx-clipboard
  :if (eq system-type 'darwin)
  :ensure t
  :config (osx-clipboard-mode +1))

(use-package osx-trash
  :if (eq system-type 'darwin)
  :ensure t)

;; misc variables
(when window-system
  (set-frame-position (selected-frame) 0 0)
  (set-frame-size (selected-frame) 192 71))
;; see also default-frame-alist and initial-frame-alist
(setq tab-width 4)          ; and 4 char wide for TAB
(setq indent-tabs-mode nil) ; And force use of spaces
(turn-on-font-lock)         ; same as syntax on in Vim
(setq inhibit-startup-screen t)
(setq vc-follow-symlinks t)
(setq scroll-step 1) ;; M-n & M-p scroll one line not many
(setq calendar-latitude 38.9047)
(setq calendar-longitude -77.0164)
(setq calendar-location-name "Washington, DC")
; Set text files to be utf-8 encoded
(add-to-list 'file-coding-system-alist '("\\.txt" . utf-8-unix) )
(add-to-list 'file-coding-system-alist '("\\.json" . utf-8-unix) )
;; Treat clipboard input as UTF-8 string first; compound text next, etc.
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))
;; ;; for homebrew install of magit... waaaaay faster than building with melpa etc.
;;(add-to-list 'load-path "/usr/local/share/emacs/site-lisp")
(setq delete-by-moving-to-trash t)
(setq exec-path (append '("/usr/local/bin")
                        exec-path))
(setq desktop-restore-eager 3)
(setq desktop-restore-forces-onscreen all)
(setq desktop-save ask-if-new)
(when window-system
  (desktop-save-mode 1)
  (tool-bar-mode -1))
(global-set-key "\C-cM" 'compile)
(global-set-key "\C-cm" 'rcompile)
(setq ediff-split-window-function split-window-vertically)


;; macOS stuff
(if (eq system-type 'darwin)
    (progn
      (setq TeX-view-program-selection '((output-pdf "PDF Viewer")))
      (setq TeX-view-program-list
	    '(("PDF Viewer" "/Applications/Skim.app/Contents/SharedSupport/displayline -b -g %n %o %b")))
      )
  )

;; put speedbar in same frame. CMD-s should toggle it...
(use-package sr-speedbar
  :ensure t
  :defer t
  :init
  (setq sr-speedbar-right-side nil)
  (setq speedbar-show-unknown-files t)
  (setq sr-speedbar-width 35)
  :bind ("s-s" . sr-speedbar-toggle))


; Display (or don't display) trailing whitespace characters using an
; unusual background color so they are visible.
(setq-default show-trailing-whitespace t)
(setq-default indicate-empty-lines t)

; Configure LaTeX stuff like Auctex
(use-package tex
	     :ensure auctex
	     :init
	     (setq TeX-auto-save t)
	     (setq TeX-parse-self t)
	     (setq-default TeX-master nil)
	     (setq TeX-PDF-mode t)
	     (setq reftex-plug-into-auctex t)
	     :config
	     (add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
	     (add-hook 'LaTeX-mode-hook 'flyspell-mode)
	     (add-hook 'LaTeX-mode-hook 'turn-on-reftex))

(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)

;; ;; Get past the acknowldegement/warning on DSRCs when using tramp
;; (defconst DSRC-tramp-prompt-regexp
;;   (concat (regexp-opt '("IF YOU DO NOT AGREE WITH THE ABOVE NOTICE, LOGOFF NOW BY TYPING \"exit\".") t)
;;           "\\s-*")
;;   "DSRC warning message regexp.")

;; (defun DSRC-tramp-action (proc vec)
;;   "Consent to DSRC warning/usage terms"
;;   (save-window-excursion
;;     (with-current-buffer (tramp-get-connection-buffer vec)
;;       (tramp-message vec 6 "\n%s" (buffer-string))
;;       (tramp-send-string vec "I agree"))))

;; (eval-after-load 'tramp-sh '(add-to-list 'tramp-actions-before-shell
;;              '(DSRC-tramp-prompt-regexp DSRC-tramp-action)))

;; Flymake
(use-package flymake-cursor
  :ensure flymake
  :init
  (setq flymake-run-in-place nil) ; nice default 4 tramp, .dir-locals.el overrides
  :bind ("C-c n" . flymake-goto-next-error)
  :bind ("C-c p" . flymake-goto-prev-error)
  )


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (auctex zenburn-theme use-package exec-path-from-shell))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
