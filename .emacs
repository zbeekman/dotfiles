;; Use use-package to create portable emacs-config
;; bootstrap emacs setup from package managers
(setq package-enable-at-startup nil)
(require 'package)
;;(setq package-archives (cons ("gnu" . "http://elpa.gnu.org/packages/")))
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl
    (warn "\
Your version of Emacs does not support SSL connections,
which is unsafe because it allows man-in-the-middle attacks.
There are two things you can do about this warning:
1. Install an Emacs version that does support SSL and be safe.
2. Remove this warning from your init file so you won't see it again."))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  (add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives "http://elpa.gnu.org/packages/")))
(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

(setq use-package-verbose t) ; verbose init debug & profiling

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))
(setq use-package-compute-statistics t)

;; Uncomment to enable debugging
(setq debug-on-error t) ; set this to get stack traces on errors

(require 'bind-key)

(use-package delight
  :ensure t)

;; Use shell/env path for exec-path
(use-package exec-path-from-shell
  :ensure t
  :config
  (exec-path-from-shell-initialize))

(use-package system-packages
  :ensure t
  :init
  (if (eq system-type 'darwin) (setq system-packages-package-manager 'brew)
    (setq system-packages-use-sudo t))
  :after exec-path-from-shell)

(use-package use-package-ensure-system-package
  :ensure t
  :after system-packages)


;; Always try to update packages
(use-package auto-package-update
  :ensure t
  :config
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-hide-results t)
  (auto-package-update-maybe)
  :after system-packages)

(use-package all-the-icons
	:ensure t)

(use-package doom-modeline
	:ensure t
	:init
	;; How tall the mode-line should be. It's only respected in GUI.
	 ;; If the actual char height is larger, it respects the actual height.
	 ;;(setq doom-modeline-height 25)

	 ;; How wide the mode-line bar should be. It's only respected in GUI.
	 ;;(setq doom-modeline-bar-width 3)

	 ;; Determines the style used by `doom-modeline-buffer-file-name'.
	 ;;
	 ;; Given ~/Projects/FOSS/emacs/lisp/comint.el
	 ;;   truncate-upto-project => ~/P/F/emacs/lisp/comint.el
	 ;;   truncate-from-project => ~/Projects/FOSS/emacs/l/comint.el
	 ;;   truncate-with-project => emacs/l/comint.el
	 ;;   truncate-except-project => ~/P/F/emacs/l/comint.el
	 ;;   truncate-upto-root => ~/P/F/e/lisp/comint.el
	 ;;   truncate-all => ~/P/F/e/l/comint.el
	 ;;   relative-from-project => emacs/lisp/comint.el
	 ;;   relative-to-project => lisp/comint.el
	 ;;   file-name => comint.el
	 ;;   buffer-name => comint.el<2> (uniquify buffer name)
	 (setq doom-modeline-buffer-file-name-style 'truncate-except-project)

	 ;; Whether display icons in mode-line or not.
	 (setq doom-modeline-icon t)

	 ;; Whether display the icon for major mode. It respects `doom-modeline-icon'.
	 (setq doom-modeline-major-mode-icon t)

	 ;; Whether display color icons for `major-mode'. It respects
	 ;; `doom-modeline-icon' and `all-the-icons-color-icons'.
	 (setq doom-modeline-major-mode-color-icon t)

	 ;; Whether display icons for buffer states. It respects `doom-modeline-icon'.
	 (setq doom-modeline-buffer-state-icon t)

	 ;; Whether display buffer modification icon. It respects `doom-modeline-icon'
	 ;; and `doom-modeline-buffer-state-icon'.
	 (setq doom-modeline-buffer-modification-icon t)

	 ;; Whether display minor modes in mode-line or not.
	 (setq doom-modeline-minor-modes nil)

	 ;; If non-nil, a word count will be added to the selection-info modeline segment.
	 (setq doom-modeline-enable-word-count nil)

	 ;; Whether display buffer encoding.
	 (setq doom-modeline-buffer-encoding t)

	 ;; Whether display indentation information.
	 (setq doom-modeline-indent-info nil)

	 ;; If non-nil, only display one number for checker information if applicable.
	 (setq doom-modeline-checker-simple-format t)

	 ;; The maximum displayed length of the branch name of version control.
	 (setq doom-modeline-vcs-max-length 24)

	 ;; Whether display perspective name or not. Non-nil to display in mode-line.
	 (setq doom-modeline-persp-name t)

	 ;; Whether display icon for persp name. Nil to display a # sign. It respects `doom-modeline-icon'
	 ;;(setq doom-modeline-persp-name-icon nil)

	 ;; Whether display `lsp' state or not. Non-nil to display in mode-line.
	 (setq doom-modeline-lsp t)

	 ;; Whether display environment version or not
	 (setq doom-modeline-env-version t)

	 ;; What to dispaly as the version while a new one is being loaded
	 (setq doom-modeline-env-load-string "...")

	:hook (after-init . doom-modeline-mode)
	:requires all-the-icons)

(use-package emacs
  :delight
  (auto-fill-function " AF")
;;  (editor-config)
  (emacs-lisp-mode "elisp" :major))

(use-package zenburn-theme
  :ensure t
  :config
  (load-theme 'zenburn t)
  )

(use-package beacon
  :ensure t
  :init
  (beacon-mode 1)
  (setq beacon-blink-duration 0.4)
  (setq beacon-blink-when-point-moves-vertically 2)
  (setq beacon-blink-when-point-moves-horizontally 2)
  (setq beacon-size 20))

(use-package smartparens-config
  :ensure smartparens
  :config (progn
	    (show-smartparens-global-mode t)
	    (require 'smartparens-config)))
(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status)
  )

;; (use-package forge
;;   :ensure t
;;   :after magit)

;; (use-package magit-todos
;;   :ensure t
;;   :after magit)

(use-package helm
  :ensure t
  :bind (("C-c h o" . helm-occur)
	 ("C-c h x" . helm-register)
	 ("C-c h g" . helm-google-suggest)
	 ("C-c h M-:" . helm-eval-expression-with-eldoc)
	 ("C-h SPC" . helm-all-mark-rings)
	 ("M-x"     . helm-M-x)
	 ("M-y"     . helm-show-kill-ring)
	 ("C-x b"   . helm-mini)
	 ("C-x C-f" . helm-find-files)
	 ("C-x C-d" . helm-browse-project)
	 ("C-x C-b" . helm-buffers-list)
	 ("C-x r b" . helm-filtered-bookmarks)
	 ([S-f10]   . helm-recentf)
	 :map helm-map
 	 ("C-i"     . helm-execute-persistent-action)
	 ("C-z"     . helm-select-action)
;	 ("<tab>"   . helm-execute-persistsent-action)
	 :map minibuffer-local-map
	 ("C-c C-l" . helm-minibuffer-history)
	 )
	:config (add-to-list 'helm-sources-using-default-as-input 'helm-source-man-pages)
	)
(require 'helm)
(require 'helm-config)
(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))

(helm-mode 1)
(helm-autoresize-mode 1)
(setq helm-split-window-in-side-p t) ; open helm buffer inside current window, not occupy whole other window
(setq helm-move-to-line-cycle-in-source t) ; move to end or beginning of source when reaching top or bottom of source.
(setq helm-ff-search-library-in-sexp t) ; search for library in `require' and `declare-function' sexp.
(setq helm-scroll-amount 8) ; scroll 8 lines other window using M-<next>/M-<prior>
(setq helm-ff-file-name-history-use-recentf t)
(setq helm-echo-input-in-header-line t)
(setq helm-completion-in-region-fuzzy-match t)
(setq helm-completion-in-region-fuzzy-match t)
(setq helm-completion-in-region-fuzzy-match t)
(setq helm-autoresize-max-height 0)
(setq helm-autoresize-min-height 20)
(when (executable-find "curl")
  (setq helm-google-suggest-use-curl-p t))

(use-package helm-descbinds
	:ensure t
	:commands helm-descbinds-mode)
(helm-descbinds-mode)

(use-package helm-ls-git
  :ensure t
  :after helm)

(use-package helm-system-packages
  :ensure t
  :after (helm system-packages))

(use-package helm-ag
   :ensure t
   :after helm
   :ensure-system-package ag
	 :after exec-path-from-shell)

(use-package helm-rg
   :ensure t
   :after helm
   :ensure-system-package
   (rg . ripgrep)
	 :after exec-path-from-shell)

(use-package wgrep
  :ensure t
  :config (require 'wgrep))

(use-package wgrep-helm
	:ensure t
	:after wgrep)

(use-package helm-flyspell
  :ensure t
  :after helm
  :bind ("C-;" . helm-flyspell-correct))

;; Remove the mode name for projectile-mode, but show the project name.
(use-package projectile
  :ensure t
  :bind-keymap
  ("C-c p" . projectile-command-map)
  ("s-p" . projectile-command-map)
  :init
	(setq projectile-enable-caching t)
	(setq projectile-switch-project-action #'projectile-find-file-dwim)
  :delight '(:eval (concat " " (projectile-project-name)))
  :config
  (projectile-global-mode)
  (setq projectile-project-search-path '("~/Sandbox/" "~/dotfiles/"))
  :after helm
  )

(use-package helm-projectile
  :ensure t
  :init
  (setq projectile-completion-system 'helm)
  (setq projectile-switch-project-action 'helm-projectile)
  :config
  (helm-projectile-on))


(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                 (if (treemacs--find-python3) 3 0)
          treemacs-deferred-git-apply-delay      0.5
          treemacs-display-in-side-window        t
          treemacs-eldoc-display                 t
          treemacs-file-event-delay              5000
          treemacs-file-follow-delay             0.2
          treemacs-follow-after-init             t
          treemacs-git-command-pipe              ""
          treemacs-goto-tag-strategy             'refetch-index
          treemacs-indentation                   2
          treemacs-indentation-string            " "
          treemacs-is-never-other-window         nil
          treemacs-max-git-entries               5000
          treemacs-missing-project-action        'ask
          treemacs-no-png-images                 nil
          treemacs-no-delete-other-windows       t
          treemacs-project-follow-cleanup        nil
          treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                      'left
          treemacs-recenter-distance             0.1
          treemacs-recenter-after-file-follow    nil
          treemacs-recenter-after-tag-follow     nil
          treemacs-recenter-after-project-jump   'always
          treemacs-recenter-after-project-expand 'on-distance
          treemacs-show-cursor                   nil
          treemacs-show-hidden-files             t
          treemacs-silent-filewatch              nil
          treemacs-silent-refresh                nil
          treemacs-sorting                       'alphabetic-desc
          treemacs-space-between-root-nodes      t
          treemacs-tag-follow-cleanup            t
          treemacs-tag-follow-delay              1.5
          treemacs-width                         38)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-tag-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode t)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null (treemacs--find-python3))))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))


(use-package treemacs-projectile
  :after treemacs projectile
  :ensure t)

(use-package treemacs-icons-dired
  :after treemacs dired
  :ensure t
  :config (treemacs-icons-dired-mode))

;; (use-package treemacs-magit
;;   :after treemacs magit
;;   :ensure t)



;; With use-package:
(use-package company-box
  :ensure t
  :hook (company-mode . company-box-mode))


;; (use-package helm-lsp
;; 	:ensure t
;; 	:commands helm-lsp-workspace-symbol)

;; (use-package lsp-mode
;;   :requires helm helm-lsp
;;   :ensure t
;;   :commands (lsp lsp-deferred)
;;   :config
;;   ;; NB: use either projectile-project-root or ffip-get-project-root-directory
;;   ;;     or any other function that can be used to find the root directory of a project
;;   (lsp-define-stdio-client lsp-python "python"
;;                            #'projectile-project-ropot
;;                            '("pyls"))

;;   ;; make sure this is activated when python-mode is activated
;;   ;; lsp-python-enable is created by macro above
;;   (add-hook 'c++-mode-hook #'lsp)
;;   (add-hook 'python-mode-hook #'lsp)
;;   (add-hook -f90-mode-hook #'lsp)
;;   (setq lsp-clients-clangd-args '("-j=4" "-background-index" "-log=error"))
;;   (setq lsp-prefer-flymake nil) ;; Prefer using lsp-ui (flycheck) over flymake.
;;   (add-hook 'lsp-mode-hook 'lsp-ui-mode))


;; (use-package lsp-ui
;;   :requires lsp-mode flycheck
;;   :config

;; 	(setq lsp-ui-sideline-ignore-duplicate t
;; 			lsp-ui-doc-enable t
;; 			lsp-ui-doc-use-childframe t
;; 			lsp-ui-doc-position 'top
;; 			lsp-ui-doc-include-signature t
;; 			lsp-ui-sideline-enable nil
;; 			lsp-ui-flycheck-enable t
;; 			lsp-ui-flycheck-list-position 'right
;; 			lsp-ui-flycheck-live-reporting t
;; 			lsp-ui-peek-enable t
;; 			lsp-ui-peek-list-width 60
;; 			lsp-ui-peek-peek-height 25)

;; 	(add-hook 'lsp-mode-hook 'lsp-ui-mode))

;; optionally if you want to use debugger
;; (use-package dap-mode
;;   :ensure t)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

(use-package company
  :config
  ;; Trigger completion immediately.
  (setq company-idle-delay 0.2)
  ;; Number the candidates (use M-1, M-2 etc to select completions).
  (setq company-show-numbers t)
  ;; Use the tab-and-go frontend.
  ;; Allows TAB to select and complete at the same time.
  ;;	(company-tng-configure-default)
  (setq company-frontends
	'(;company-tng-frontend
	  company-pseudo-tooltip-frontend
	  company-echo-metadata-frontend))
  (global-company-mode 1)
  (global-set-key (kbd "M-<tab>") 'company-complete))

(use-package company-tabnine
	:ensure t
	:requires company
	:config
	(push 'company-tabnine company-backends))

;; (use-package company-lsp
;;   :ensure t
;;   :requires company
;;   :config
;;   (push 'company-lsp company-backends)

;;    ;; Disable client-side cache because the LSP server does a better job.
;;   (setq company-transformers nil
;;         company-lsp-async t
;;         company-lsp-cache-candidates nil))

;; 	(use-package lsp-treemacs
;; 		:ensure t
;; 		:commands lsp-treemacs-errors-list)


;; Starts the Emacs server when window system
(use-package edit-server
  :if window-system
  :ensure t
  :init
  (add-hook 'after-init-hook 'server-start t)
  (add-hook 'after-init-hook 'edit-server-start t))

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

(use-package ws-butler
  :ensure t
  :config (ws-butler-global-mode))

(use-package ag
  :ensure t
  :ensure-system-package
  (ag . silversearcher-ag)
  :config
  (setq ag-highlight-search t)
  (setq ag-reuse-buffers 't)
  )

(use-package editorconfig
  :ensure t
  :after ws-butler
  :init
  (setq editorconfig-trim-whitespaces-mode
         'ws-butler-mode)
  :config
  (editorconfig-mode 1)
  ;; Always use tabs for Makefiles
  (add-hook 'editorconfig-hack-properties-functions
	    '(lambda (props)
	       (when (derived-mode-p 'makefile-mode)
		 (puthash 'indent_style "tab" props)))))

;; misc variables
(setq-default indent-tabs-mode nil)
(setq-default standard-indent 2)
(setq f90-smart-end-names nil)
(setq f90-beginning-ampersand nil)
(setq transient-mark-mode t)
(setq tab-width 2)          ; and 4 char wide for TAB
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
(setq imenu-max-items 300)
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
  :ensure t
  :after flymake
  :init
  (setq flymake-run-in-place nil) ; nice default 4 tramp, .dir-locals.el overrides
  :bind ("C-c f n" . flymake-goto-next-error)
  :bind ("C-c f p" . flymake-goto-prev-error)
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

(use-package markdown-toc
  :ensure t
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . gfm-mode)
         ("\\.markdown\\'" . markdown-mode)))

(use-package yaml-mode
  :ensure t
  :commands (yaml-mode)
  :mode (("\\.yml\\'" . yaml-mode)
         ("\\.yaml\\'" . yaml-mode)))

;; See https://github.com/Lindydancer/cmake-font-lock/issues/5
(use-package cmake-mode
  :ensure t
  :ensure-system-package cmake
  :commands (cmake-mode)
  :mode (("CMakeLists\\.txt\\'" . cmake-mode)
		("\\.cmake\\'" . cmake-mode))
  :config
  (use-package cmake-font-lock
    :ensure t
    :defer t
    :commands (cmake-font-lock-activate)
    :hook (cmake-mode . (lambda ()
                          (cmake-font-lock-activate)))
    )
  )

(use-package docker
  :ensure t
  :bind ("C-c d" . docker))

(use-package dockerfile-mode
  :ensure t
  :mode (("\\Dockerfile'" . dockerfile-mode)))

(use-package highlight-parentheses
  :ensure t
  :init (global-highlight-parentheses-mode))

;; (use-package smart-tab
;;   :ensure t
;;   :commands (global-smart-tab-mode)
;;   :init
;;   (global-smart-tab-mode 1)
;;   (setq smart-tab-using-hippie-expand t))


(use-package elpy
  :ensure t
  :commands (elpy-use-ipython)
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

;;(use-package ein
;;  :ensure t
;;  :init
;;  (setq
;;   ein:use-auto-complete t
;;   ein:complete-on-dot t)
;;  )

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

;; (use-package bug-reference-github
;;   :ensure t
;;   :init
;;   (add-hook 'find-file-hook 'bug-reference-github-set-url-format)
;;   (add-hook 'prog-mode-hook 'bug-reference-prog-mode)
;;   )

;; (use-package gh
;;   :ensure t
;;   :defer t)

(use-package git-messenger
  :ensure t
  :ensure-system-package git)

;; (use-package github-browse-file
;;   :ensure t)


;; Recent file menu/opening from mastering emacs
(require 'recentf)
;; enable recent files mode.
(recentf-mode t)
;; get rid of `find-file-read-only' and replace it with something
;; more useful.

;; (setq hippie-expand-try-functions-list
;;       '(try-expand-dabbrev-visible try-expand-dabbrev try-expand-all-abbrevs try-expand-dabbrev-from-kill try-expand-dabbrev-all-buffers try-complete-file-name-partially try-complete-file-name try-expand-list try-expand-line))


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
 '(column-number-mode t)
 '(company-quickhelp-color-background "#4F4F4F")
 '(company-quickhelp-color-foreground "#DCDCCC")
 '(custom-safe-themes
	 (quote
		("190a9882bef28d7e944aa610aa68fe1ee34ecea6127239178c7ac848754992df" default)))
 '(doom-modeline-mode t)
 '(fci-rule-color "#383838")
 '(nrepl-message-colors
	 (quote
		("#CC9393" "#DFAF8F" "#F0DFAF" "#7F9F7F" "#BFEBBF" "#93E0E3" "#94BFF3" "#DC8CC3")))
 '(package-archives
	 (quote
		(("gnu" . "http://elpa.gnu.org/packages/")
		 ("melpa" . "https://melpa.org/packages/")
		 ("melpa-stable" . "https://stable.melpa.org/packages/"))))
 '(package-selected-packages
	 (quote
		(magit smartparens doom-modeline all-the-icons helm-ag projectile-ripgrep ripgrep helm-rg wgrep-helm wgrep-ag wgrep company-tabnine helm-projectile company-box lsp-treemacs helm-lsp company-lsp lsp-ui spinner lsp-mode treemacs-icons-dired treemacs-projectile treemacs helm-system-packages helm-ls-git projectile helm-flyspell helm flymake-cursor use-package auto-package-update delight tide tss ws-butler markdown-toc docker dockerfile-mode ein cmake-font-lock travis highlight-parentheses auctex exec-path-from-shell)))
 '(pdf-view-midnight-colors (quote ("#DCDCCC" . "#383838")))
 '(safe-local-variable-values
	 (quote
		((projectile-project-compilation-dir . "build")
		 (projectile-project-name . "FAST")
		 (projectile-project-configure-cmd . "cmake -Wdev -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON")
		 (projectile-project-compilation-dir . build))))
 '(save-place-mode t)
 '(tool-bar-mode nil)
 '(treemacs-tag-follow-mode t)
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
