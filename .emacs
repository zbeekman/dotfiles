;; ;; Uncomment to enable debugging
;;(setq debug-on-error t) ; set this to get stack traces on errors

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
(use-package zenburn-theme
  :if window-system
  :ensure t
  :config
  (load-theme 'zenburn)
  )

;; Starts the Emacs server when window system
(use-package edit-server
  :if window-system
  :init
  (add-hook 'after-init-hook 'server-start t)
  (add-hook 'after-init-hook 'edit-server-start t))

;; Use shell/env path for exec-path
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :ensure t
  :config
  (exec-path-from-shell-initialize))

;; misc variables
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

;; ;; macOS stuff
;; (if (eq system-type 'darwin)
;;     (progn (setenv "PATH" (concat "/usr/local/bin" (getenv "PATH")))
;; 	   (osx-clipboard-mode +1)
;; 	   (osx-trash-setup)
;; 	   (setq delete-by-moving-to-trash t)
;; 	   (setq exec-path (prepend exec-path '("/usr/local/bin")))
;; 	   ;; use Skim as default pdf viewer Skim's displayline is used for
;; 	   ;; forward search (from .tex to .pdf) option -b highlights the current
;; 	   ;; line; option -g opens Skim in the background
;; 	   (setq TeX-view-program-selection '((output-pdf "PDF Viewer")))
;; 	   (setq TeX-view-program-list
;; 		 '(("PDF Viewer" "/Applications/Skim.app/Contents/SharedSupport/displayline -b -g %n %o %b")))
;; 	   ;; (if (file-executable-p "/usr/local/bin/aspell")
;; 	   ;;     (progn
;; 	   ;; 	 (setq ispell-program-name "/usr/local/bin/aspell")
;; 	   ;; 	 (setq ispell-extra-args '("-d" "/Library/Application Support/cocoAspell/aspell6-en-6.0-0/en.multi"))
;; 	   ;; 	 ))
;; 	   ))

;; put speedbar in same frame. CMD-s should toggle it...
(use-package sr-speedbar
	     :bind ("s-s" . sr-speedbar-toggle))


; Display (or don't display) trailing whitespace characters using an
; unusual background color so they are visible.
(setq-default show-trailing-whitespace t)
(setq-default indicate-empty-lines t)

; Use yaml-mode for YAML files
(use-package yaml-mode
	     :mode
	     (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode)))

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
(use-package flymake
	     :init
	     (setq flymake-run-in-place nil) ; nice default 4 tramp, .dir-locals.el overrides
	     :config
