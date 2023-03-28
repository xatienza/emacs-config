;;; init.el --- Initialization file for Emacs
;;; Commentary: Emacs Startup File --- initialization for Emacs

(setq user-full-name "Xavier Sánchez Atienza"
      user-mail-address "xaviersanchez@dorna.com")

;; Set F9 as other-window key. c-x o is missing.
(global-set-key [f9] 'other-window)

;; Initialize package sources
(require 'package)
(when (not (assoc "melpa" package-archives))
  (setq package-archives (append '(("stable" . "https://stable.melpa.org/packages/")) package-archives))
  (setq package-archives (append '(("melpa" . "https://melpa.org/packages/")) package-archives))
  (setq package-archives (append '(("gnu" . "https://elpa.gnu.org/packages/")) package-archives)))
(package-initialize)

;; refresh package list if it is not already available
(when (not package-archive-contents) (package-refresh-contents))

;; install use-package if it isn't already installed
(when (not (package-installed-p 'use-package))
  (package-install 'use-package))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Install and configure pacakges

(setq fit-window-to-buffer-horizontally t)

(add-hook 'after-init-hook 'global-flycheck-mode)
(add-hook 'after-init-hook 'global-company-mode)
(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-golangci-lint-setup))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(docker dockerfile-mode ox-pandoc which-key smex geben-helm-projectile org-projectile minimap elscreen-multi-term yasnippet swiper helm-projectile helm expand-region smartparens diff-hl org-bullets gotest company lsp-ui flycheck-golangci-lint go-mode switch-window ace-window magit lsp-mode org-modern projectile flycheck monokai-theme)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; starts Smex
(use-package smex
  :ensure t
  :config
  (smex-initialize))

;; start which-key
(use-package which-key
  :defer 10
  :ensure t
  :config
  (which-key-setup-minibuffer)
  (which-key-mode 1))

;; use golangci
(use-package flycheck-golangci-lint
  :ensure t)

;; Move between windows Shit-<arrow>
(windmove-default-keybindings)
(setq windmove-wrap-around t)

;; Load monokai-theme
(load-theme 'monokai t)

;; Enable clipboard-copy
(setq x-select-enable-clipboard t)

;;Enable neotree package
(require 'neotree)
(global-set-key [f8] 'neotree-toggle)


;; Set default directory
(setq default-directory "~./projects")

;; default setup pro org-mode (orgmode.org)
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)
(setq org-ellipsis "⤵")
;; org bullets
(use-package org-bullets :ensure t)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
(setq org-hide-leading-stars t)
;; Org syntax highlighting
(setq org-src-fontify-natively t)
;; Highlight uncommited changes
(use-package diff-hl
  :config
  (add-hook 'prog-mode-hook 'turn-on-diff-hl-mode)
  (add-hook 'vc-dir-mode-hook 'turn-on-diff-hl-mode))

;;Hihlight current line
(global-hl-line-mode)

;;Smartparents
(use-package smartparens
  :ensure t
  :diminish smartparens-mode
  :config
  (progn
    (require 'smartparens-config)
    (smartparens-global-mode 1)
    (show-paren-mode t)))

;; expand-region
(use-package expand-region
  :ensure t
  :bind ("M-m" . er/expand-region))

;; Tabs
(setq-default tab-width 4
              indent-tabs-mode nil)

;; Project Management
(use-package flycheck)
(use-package company)
(add-hook 'after-init-hook 'global-company-mode)


;; Projectile config.
(use-package projectile
  :ensure t
  :diminish projectile-mode
  :bind 
  (("C-c p f" . helm-projectile-find-file)
   ("C-c p p" . helm-projectile-switch-project)
   ("C-c p s" . projectile-save-project-buffers))
  :config
  (projectile-mode +1)
)

(use-package helm
  :ensure t
  :defer 2
  :bind
  ("M-x" . helm-M-x)
  ("C-x C-f" . helm-find-files)
  ("M-y" . helm-show-kill-ring)
  ("C-x b" . helm-mini)
  ("C-s" . helm-occur-from-isearch)
  :config
  (helm-mode 1)
  (setq helm-locate-fuzzy-match t)
  (setq helm-split-window-inside-p t
    helm-move-to-line-cycle-in-source t)
  (setq helm-autoresize-max-height 0)
  (setq helm-autoresize-min-height 20)
  (helm-autoresize-mode 1)
  (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
  (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB work in terminal
  (define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z
  )

(use-package helm-projectile
  :ensure t
  :config
  (helm-projectile-on))

(use-package golden-ratio :ensure t)
(golden-ratio-mode 1)

(use-package swiper
  :ensure t)

(use-package swiper :ensure t
:config (progn (global-set-key "\C-s" 'swiper)))


(setq lsp-gopls-staticcheck t)
(setq lsp-eldoc-render-all t)
(setq lsp-gopls-complete-unimported t)

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (go-mode . lsp-deferred))

;;Set up before-save hooks to format buffer and add/delete imports.
;;Make sure you don't have other gofmt/goimports hooks enabled.

(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;;Optional - provides fancier overlays.

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :init
)

;;Company mode is a standard completion package that works well with lsp-mode.
;;company-lsp integrates company mode completion with lsp-mode.
;;completion-at-point also works out of the box but doesn't support snippets.

(use-package company
  :ensure t
  :config
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 1))

;;Optional - provides snippet support.

(use-package yasnippet
  :ensure t
  :commands yas-minor-mode
  :hook (go-mode . yas-minor-mode))

;;lsp-ui-doc-enable is false because I don't like the popover that shows up on the right
;;I'll change it if I want it back


(setq lsp-ui-doc-enable nil
      lsp-ui-peek-enable t
      lsp-ui-sideline-enable t
      lsp-ui-imenu-enable t
      lsp-ui-flycheck-enable t)

;; Multi-terminal
(use-package multi-term)
(global-set-key (kbd "C-c t") 'multi-term)

;; pkg go installation
(setq exec-path (append '("/usr/bin") exec-path))
(setenv "PATH" (concat "/usr/bin:" (getenv "PATH")))

;; As-you-type error highlighting
(add-hook 'after-init-hook #'global-flycheck-mode)

(defun custom-go-mode ()
  (display-line-numbers-mode 1))

(use-package go-mode
:defer t
:ensure t
:mode ("\\.go\\'" . go-mode)
:init
  (setq compile-command "echo Building... && go build -v && echo Testing... && go test -v && echo Linter... && golint")
  (setq compilation-read-command nil)
  (add-hook 'go-mode-hook 'custom-go-mode)
:bind (("M-," . compile)
("M-." . godef-jump)))

(setq compilation-window-height 14)
(defun my-compilation-hook ()
  (when (not (get-buffer-window "*compilation*"))
    (save-selected-window
      (save-excursion
    (let* ((w (split-window-vertically))
           (h (window-height w)))
      (select-window w)
      (switch-to-buffer "*compilation*")
      (shrink-window (- h compilation-window-height)))))))
(add-hook 'compilation-mode-hook 'my-compilation-hook)

(global-set-key (kbd "C-c C-c") 'comment-or-uncomment-region)
(setq compilation-scroll-output t)

;; Use projectile-test-project in place of 'compile'; assign whatever key you want.
(global-set-key [f7] 'projectile-test-project)

;; "projectile" recognizes git repos (etc) as "projects" and changes settings
;; as you switch between them.
(projectile-global-mode 1)

;; Docker setup
(use-package docker
  :ensure t
  :bind ("C-c d" . docker))
