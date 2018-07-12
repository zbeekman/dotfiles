;; Use use-package to create portable emacs-config
;; bootstrap emacs setup from package managers
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))
(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(setq use-package-verbose t) ; verbose init debug & profiling

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

;; Uncomment to enable debugging
(setq debug-on-error t) ; set this to get stack traces on errors

(require 'bind-key)

(setq use-package-verbose t) ; verbose init debug & profiling

(use-package diminish
  :ensure t)

(use-package zenburn-theme
  :ensure t
  :config
  (load-theme 'zenburn t)
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

(use-package homebrew-mode
  :ensure t
  :if (eq system-type 'darwin)
  :config (global-homebrew-mode))


(use-package travis
  :ensure t)

;; Always use recentf

;; misc variables
(setq f90-smart-end-names nil)
(when window-system
  (set-frame-position (selected-frame) 0 0)
  (set-frame-size (selected-frame) 192 71))
;; see also default-frame-alist and initial-frame-alist
(setq redisplay-dont-pause t) ; better performance, maybe...
(setq transient-mark-mode t)
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
(modify-coding-system-alist 'file "\\.txt\\'"  'utf-8-unix)
(modify-coding-system-alist 'file "\\.json\\'" 'utf-8-unix)
(modify-coding-system-alist 'file "\\.bat\\'" 'us-ascii-dos)
;; Treat clipboard input as UTF-8 string first; compound text next, etc.
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))
;; ;; for homebrew install of magit... waaaaay faster than building with melpa etc.
;;(add-to-list 'load-path "/usr/local/share/emacs/site-lisp")
(setq delete-by-moving-to-trash t)
(setq exec-path (append '("/usr/local/bin")
                        exec-path))
(setq desktop-restore-eager 3)
(setq desktop-restore-forces-onscreen 'all)
(setq desktop-save 'ask-if-new)
(when window-system
  (desktop-save-mode 1)
  (tool-bar-mode -1))
(global-set-key "\C-cM" 'compile)
(global-set-key "\C-cm" 'rcompile)
(setq ediff-split-window-function 'split-window-horizontally)
(setq imenu-auto-rescan t)
(setq imenu-max-items 50)
(setq imenu-sort-function 'imenu--sort-by-name)
;; backups
(setq make-backup-files 'non-nil)
(setq
   backup-by-copying t       ; don't clobber symlinks
   backup-directory-alist
    '(("." . "~/.saves"))    ; don't litter my fs tree
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 3
   version-control t)
; default to unified diffs
(setq diff-switches "-u")

;; macOS stuff
(if (eq system-type 'darwin)
    (progn
      (setq TeX-view-program-selection '((output-pdf "PDF Viewer")))
      (setq TeX-view-program-list
            '(("PDF Viewer" "/Applications/Skim.app/Contents/SharedSupport/displayline -b -g %n %o %b")))
    ;; ;;; Fira code
    ;;   (when window-system
    ;;     ;; This works when using emacs --daemon + emacsclient
    ;;     (add-hook 'after-make-frame-functions (lambda (frame) (set-fontset-font t '(#Xe100 . #Xe16f) "Fira Code Symbol")))
    ;;     ;; This works when using emacs without server/client
    ;;     (set-fontset-font t '(#Xe100 . #Xe16f) "Fira Code Symbol")
    ;;     ;; I haven't found one statement that makes both of the above situations work, so I use both for now

    ;;     (defconst fira-code-font-lock-keywords-alist
    ;;       (mapcar (lambda (regex-char-pair)
    ;;                 `(,(car regex-char-pair)
    ;;                   (0 (prog1 ()
    ;;                        (compose-region (match-beginning 1)
    ;;                                        (match-end 1)
    ;;                                        ;; The first argument to concat is a string containing a literal tab
    ;;                                        ,(concat "	" (list (decode-char 'ucs (cadr regex-char-pair)))))))))
    ;;               '(;("\\(www\\)"                   #Xe100)
    ;;                 ("[^/]\\(\\*\\*\\)[^/]"        #Xe101)
    ;;                 ("\\(\\*\\*\\*\\)"             #Xe102)
    ;;                 ("\\(\\*\\*/\\)"               #Xe103)
    ;;                 ("\\(\\*>\\)"                  #Xe104)
    ;;                 ("[^*]\\(\\*/\\)"              #Xe105)
    ;;                 ("\\(\\\\\\\\\\)"              #Xe106)
    ;;                 ("\\(\\\\\\\\\\\\\\)"          #Xe107)
    ;;                 ("\\({-\\)"                    #Xe108)
    ;;                 ("\\(\\[\\]\\)"                #Xe109)
    ;;                 ("\\(::\\)"                    #Xe10a)
    ;;                 ("\\(:::\\)"                   #Xe10b)
    ;;                 ("[^=]\\(:=\\)"                #Xe10c)
    ;;                 ("\\(!!\\)"                    #Xe10d)
    ;;                 ("\\(!=\\)"                    #Xe10e)
    ;;                 ("\\(/=\\)"                    #Xe10e) ;; For Fortran, will mess up some languages
    ;;                 ("\\(!==\\)"                   #Xe10f)
    ;;                 ("\\(-}\\)"                    #Xe110)
    ;;                 ("\\(--\\)"                    #Xe111)
    ;;                 ("\\(---\\)"                   #Xe112)
    ;;                 ("\\(-->\\)"                   #Xe113)
    ;;                 ("[^-]\\(->\\)"                #Xe114)
    ;;                 ("\\(->>\\)"                   #Xe115)
    ;;                 ("\\(-<\\)"                    #Xe116)
    ;;                 ("\\(-<<\\)"                   #Xe117)
    ;;                 ("\\(-~\\)"                    #Xe118)
    ;;                 ("\\(#{\\)"                    #Xe119)
    ;;                 ("\\(#\\[\\)"                  #Xe11a)
    ;;                 ("\\(##\\)"                    #Xe11b)
    ;;                 ("\\(###\\)"                   #Xe11c)
    ;;                 ("\\(####\\)"                  #Xe11d)
    ;;                 ("\\(#(\\)"                    #Xe11e)
    ;;                 ("\\(#\\?\\)"                  #Xe11f)
    ;;                 ("\\(#_\\)"                    #Xe120)
    ;;                 ("\\(#_(\\)"                   #Xe121)
    ;;                 ("\\(\\.-\\)"                  #Xe122)
    ;;                 ("\\(\\.=\\)"                  #Xe123)
    ;;                 ("\\(\\.\\.\\)"                #Xe124)
    ;;                 ("\\(\\.\\.<\\)"               #Xe125)
    ;;                 ("\\(\\.\\.\\.\\)"             #Xe126)
    ;;                 ("\\(\\?=\\)"                  #Xe127)
    ;;                 ("\\(\\?\\?\\)"                #Xe128)
    ;;                 ("\\(;;\\)"                    #Xe129)
    ;;                 ("\\(/\\*\\)"                  #Xe12a)
    ;;                 ("\\(/\\*\\*\\)"               #Xe12b)
    ;;                 ;;            ("\\(/=\\)"                    #Xe12c)
    ;;                 ("\\(/==\\)"                   #Xe12d)
    ;;                 ("\\(/>\\)"                    #Xe12e)
    ;;                 ("\\(//\\)"                    #Xe12f)
    ;;                 ("\\(///\\)"                   #Xe130)
    ;;                 ("\\(&&\\)"                    #Xe131)
    ;;                 ("\\(||\\)"                    #Xe132)
    ;;                 ("\\(||=\\)"                   #Xe133)
    ;;                 ("[^|]\\(|=\\)"                #Xe134)
    ;;                 ("\\(|>\\)"                    #Xe135)
    ;;                 ("\\(\\^=\\)"                  #Xe136)
    ;;                 ("\\(\\$>\\)"                  #Xe137)
    ;;                 ("\\(\\+\\+\\)"                #Xe138)
    ;;                 ("\\(\\+\\+\\+\\)"             #Xe139)
    ;;                 ("\\(\\+>\\)"                  #Xe13a)
    ;;                 ("\\(=:=\\)"                   #Xe13b)
    ;;                 ("[^!/]\\(==\\)[^>]"           #Xe13c)
    ;;                 ("\\(===\\)"                   #Xe13d)
    ;;                 ("\\(==>\\)"                   #Xe13e)
    ;;                 ("[^=]\\(=>\\)"                #Xe13f)
    ;;                 ("\\(=>>\\)"                   #Xe140)
    ;;                 ("\\(<=\\)"                    #Xe141)
    ;;                 ("\\(=<<\\)"                   #Xe142)
    ;;                 ("\\(=/=\\)"                   #Xe143)
    ;;                 ("\\(>-\\)"                    #Xe144)
    ;;                 ("\\(>=\\)"                    #Xe145)
    ;;                 ("\\(>=>\\)"                   #Xe146)
    ;;                 ("[^-=]\\(>>\\)"               #Xe147)
    ;;                 ("\\(>>-\\)"                   #Xe148)
    ;;                 ("\\(>>=\\)"                   #Xe149)
    ;;                 ("\\(>>>\\)"                   #Xe14a)
    ;;                 ("\\(<\\*\\)"                  #Xe14b)
    ;;                 ("\\(<\\*>\\)"                 #Xe14c)
    ;;                 ("\\(<|\\)"                    #Xe14d)
    ;;                 ("\\(<|>\\)"                   #Xe14e)
    ;;                 ("\\(<\\$\\)"                  #Xe14f)
    ;;                 ("\\(<\\$>\\)"                 #Xe150)
    ;;                 ("\\(<!--\\)"                  #Xe151)
    ;;                 ("\\(<-\\)"                    #Xe152)
    ;;                 ("\\(<--\\)"                   #Xe153)
    ;;                 ("\\(<->\\)"                   #Xe154)
    ;;                 ("\\(<\\+\\)"                  #Xe155)
    ;;                 ("\\(<\\+>\\)"                 #Xe156)
    ;;                 ("\\(<=\\)"                    #Xe157)
    ;;                 ("\\(<==\\)"                   #Xe158)
    ;;                 ("\\(<=>\\)"                   #Xe159)
    ;;                 ("\\(<=<\\)"                   #Xe15a)
    ;;                 ("\\(<>\\)"                    #Xe15b)
    ;;                 ("[^-=]\\(<<\\)"               #Xe15c)
    ;;                 ("\\(<<-\\)"                   #Xe15d)
    ;;                 ("\\(<<=\\)"                   #Xe15e)
    ;;                 ("\\(<<<\\)"                   #Xe15f)
    ;;                 ("\\(<~\\)"                    #Xe160)
    ;;                 ("\\(<~~\\)"                   #Xe161)
    ;;                 ("\\(</\\)"                    #Xe162)
    ;;                 ("\\(</>\\)"                   #Xe163)
    ;;                 ("\\(~@\\)"                    #Xe164)
    ;;                 ("\\(~-\\)"                    #Xe165)
    ;;                 ("\\(~=\\)"                    #Xe166)
    ;;                 ("\\(~>\\)"                    #Xe167)
    ;;                 ("[^<]\\(~~\\)"                #Xe168)
    ;;                 ("\\(~~>\\)"                   #Xe169)
    ;;                 ("\\(%%\\)"                    #Xe16a)
    ;;                 ;; ("\\(x\\)"                   #Xe16b) This ended up being hard to do properly so i'm leaving it out.
    ;;                 ("[^:=]\\(:\\)[^:=]"           #Xe16c)
    ;;                 ("[^\\+<>]\\(\\+\\)[^\\+<>]"   #Xe16d)
    ;;                 ("[^\\*/<>]\\(\\*\\)[^\\*/<>]" #Xe16f))))

    ;;     (defun add-fira-code-symbol-keywords ()
    ;;       (font-lock-add-keywords nil fira-code-font-lock-keywords-alist))

    ;;     (add-hook 'prog-mode-hook
    ;;               #'add-fira-code-symbol-keywords)
    ;;     )
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

;; Configure LaTeX stuff like Auctex
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

;; Use flycheck for some stuff
(use-package flycheck
  :ensure t
  :init (add-hook 'sh-mode-hook 'flycheck-mode)
  )

;; Markdown support
;; https://jblevins.org/projects/markdown-mode/
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . gfm-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

(use-package yaml-mode
  :ensure t
  :commands (yaml-mode)
  :mode (("\\.yml\\'" . yaml-mode)
         ("\\.yaml\\'" . yaml-mode)))

;; See https://github.com/Lindydancer/cmake-font-lock/issues/5
(use-package cmake-mode
  :ensure t
  :commands (cmake-mode)
  :mode (("CMakeLists\\.txt\\'" . cmake-mode)
		("\\.cmake\\'" . cmake-mode))
  :config
  (use-package cmake-font-lock
    :ensure t
    :defer t
    :commands (cmake-font-lock-activate)
    :hook (cmake-mode . (lambda ()
                          (message "\nActivating font lock?\n")
                          (cmake-font-lock-activate)))
    )
  )

(use-package highlight-parentheses
  :ensure t
  :init (global-highlight-parentheses-mode))

(use-package smart-tab
  :ensure t
  :commands (global-smart-tab-mode)
  :init
  (global-smart-tab-mode 1)
  (setq smart-tab-using-hippie-expand t))


(use-package elpy
  :ensure t
  :commands (elpy-use-ipython)
  :init
  (elpy-enable)
  :config
  (when (require 'flycheck nil t)
    (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
    (add-hook 'elpy-mode-hook 'flycheck-mode))
  )

(use-package python
  :ensure t
  :config
  (setq python-shell-interpreter "jupyter"
	python-shell-interpreter-args "console --simple-prompt"
	python-shell-prompt-detect-failure-warning nil)
  (add-to-list 'python-shell-completion-native-disabled-interpreters
               "jupyter")
  )

(use-package ein
  :ensure t
  :init
  (setq
   ein:use-auto-complete t
   ein:complete-on-dot t)
  )

(use-package term
  :ensure t
  :bind
  (:map term-mode-map
	("M-p" . term-send-up)
	("M-n" . term-send-down)
   :map term-raw-map
        ("M-o" . other-window)
	("M-p" . term-send-up)
	("M-n" . term-send-down)))

(use-package bug-reference-github
  :ensure t
  :init
  (add-hook 'find-file-hook 'bug-reference-github-set-url-format)
  (add-hook 'prog-mode-hook 'bug-reference-prog-mode)
  )

(use-package gh
  :ensure t
  :defer t)

(use-package git-messenger
  :ensure t)

(use-package github-browse-file
  :ensure t)


;; Recent file menu/opening from mastering emacs
(require 'recentf)
;; get rid of `find-file-read-only' and replace it with something
;; more useful.
(global-set-key (kbd "C-x C-r") 'ido-recentf-open)
;; enable recent files mode.
(recentf-mode t)
; 100 files ought to be enough.
(setq recentf-max-saved-items 100)
(defun ido-recentf-open ()
  "Use `ido-completing-read' to \\[find-file] a recent file"
  (interactive)
  (if (find-file (ido-completing-read "Find recent file: " recentf-list))
      (message "Opening file...")
    (message "Aborting")))
;; http://www.masteringemacs.org/articles/2011/01/27/find-files-faster-recent-files-package/
;; Give IDO mode a shot
(setq ido-everywhere t)
(setq ido-max-directory-size 100000)
(ido-mode (quote both))
; Use the current window when visiting files and buffers with ido
(setq ido-default-file-method 'selected-window)
(setq ido-default-buffer-method 'selected-window)
(setq ido-enable-flex-matching t)
(ido-mode 1)
(setq ido-use-filename-at-point 'guess)
(setq ido-file-extensions-order '(".F90" ".f90" ".pbs" ".inp" ".sh" ".el" ".py" ".cmd" ".txt"))
(setq ido-create-new-buffer 'prompt)
;;(setq ido-ignore-extensions t)
;;http://www.masteringemacs.org/articles/2010/10/10/introduction-to-ido-mode/
;; Hippie expand customizations
(setq hippie-expand-try-functions-list
      '(try-expand-dabbrev-visible try-expand-dabbrev try-expand-all-abbrevs try-expand-dabbrev-from-kill try-expand-dabbrev-all-buffers try-complete-file-name-partially try-complete-file-name try-expand-list try-expand-line))


;; Make certain files executable by default w/ shebang magic
(setq my-shebang-patterns
      (list "^#!/usr/.*/perl\\(\\( \\)\\|\\( .+ \\)\\)-w *.*"
	    "^#!/usr/.*/sh"
	    "^#!/usr/.*/bash"
	    "^#!/usr/bin/env bash"
	    "^#!/bin/sh"
	    "^#!/bin/bash"
	    "^#!/usr/bin/env python"
	    "^#!/bin/sed -f"
	    "^#!/bin/awk -f"
	    "^#!/usr/bin/awk -f"))
(add-hook
 'after-save-hook
 (lambda ()
   (if (not (= (shell-command (concat "test -x " (buffer-file-name))) 0))
       (progn
	 ;; This puts message in *Message* twice, but minibuffer
	 ;; output looks better.
	 (message (concat "Wrote " (buffer-file-name)))
	 (save-excursion
	   (goto-char (point-min))
	   ;; Always checks every pattern even after
	   ;; match.  Inefficient but easy.
	   (dolist (my-shebang-pat my-shebang-patterns)
	     (if (looking-at my-shebang-pat)
		 (if (= (shell-command
			 (concat "chmod u+x " (buffer-file-name)))
			0)
		     (message (concat
			       "Wrote and made executable "
			       (buffer-file-name))))))))
     ;; This puts message in *Message* twice, but minibuffer output
     ;; looks better.
     (message (concat "Wrote " (buffer-file-name))))))

;; F90 mode settings
(add-hook 'f90-mode-hook
          '(lambda ()
	     (setq f90-beginning-ampersand nil)
	     (f90-add-imenu-menu)
;;	     (abbrev-mode 1)
	     (hide-ifdef-mode)
	     ))

(add-hook 'prog-mode-hook
	  '(lambda ()
	     (column-number-mode t)
	     (which-func-mode 1)
	     (flyspell-prog-mode)
	     (electric-pair-mode)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#3F3F3F" "#CC9393" "#7F9F7F" "#F0DFAF" "#8CD0D3" "#DC8CC3" "#93E0E3" "#DCDCCC"])
 '(company-quickhelp-color-background "#4F4F4F")
 '(company-quickhelp-color-foreground "#DCDCCC")
 '(custom-safe-themes
   (quote
    ("190a9882bef28d7e944aa610aa68fe1ee34ecea6127239178c7ac848754992df" default)))
 '(fci-rule-color "#383838")
 '(nrepl-message-colors
   (quote
    ("#CC9393" "#DFAF8F" "#F0DFAF" "#7F9F7F" "#BFEBBF" "#93E0E3" "#94BFF3" "#DC8CC3")))
 '(package-selected-packages
   (quote
    (ein elpy cmake-font-lock flycheck travis smart-tab highlight-parentheses auctex zenburn-theme use-package exec-path-from-shell)))
 '(pdf-view-midnight-colors (quote ("#DCDCCC" . "#383838")))
 '(vc-annotate-background "#2B2B2B")
 '(vc-annotate-color-map
   (quote
    ((20 . "#BC8383")
     (40 . "#CC9393")
     (60 . "#DFAF8F")
     (80 . "#D0BF8F")
     (100 . "#E0CF9F")
     (120 . "#F0DFAF")
     (140 . "#5F7F5F")
     (160 . "#7F9F7F")
     (180 . "#8FB28F")
     (200 . "#9FC59F")
     (220 . "#AFD8AF")
     (240 . "#BFEBBF")
     (260 . "#93E0E3")
     (280 . "#6CA0A3")
     (300 . "#7CB8BB")
     (320 . "#8CD0D3")
     (340 . "#94BFF3")
     (360 . "#DC8CC3"))))
 '(vc-annotate-very-old-color "#DC8CC3"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
