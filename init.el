;;; init.el --- Jed Clinger's Emacs configuration -*- lexical-binding: t -*-

;; Copyright (C) 2016 Jedidiah T Clinger

;;; Commentary:

;; My init.el was initially based on the structure of Magnar Sveen's
;; .emacs found here: https://github.com/magnars/.emacs.d
;;
;; I have since refactored it to a use-package based config. Most of
;; my config resides in this file.
;;
;; This config is not designed to work generically for multiple
;; users. It is custom tailored to my needs.
;;
;; There is currently no well defined order to my use-package declarations.

;;; Code:

(package-initialize)

;; Get rid of UI menu bars and stuff (comment out if you want that
;; stuff).
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(setq inhibit-startup-message t)

;; Set path to dependencies
(setq user-init-file (or load-file-name (buffer-file-name)))
(setq user-emacs-directory (file-name-directory user-init-file))
(defvar site-lisp-dir (expand-file-name "site-lisp" user-emacs-directory))
(defvar settings-dir (expand-file-name "settings" user-emacs-directory))
;; (defvar presentations-dir (expand-file-name "presentations" user-emacs-directory))

(defvar elisp-dirs
  (list site-lisp-dir
        settings-dir
        (expand-file-name "site-lisp/timonier" user-emacs-directory)
        (expand-file-name "site-lisp/graphql-mode" user-emacs-directory)
        ;; presentations-dir
        ))

;; Set up load path
(dolist (dir elisp-dirs)
  (add-to-list 'load-path dir)
  (let ((default-directory dir))
    (normal-top-level-add-subdirs-to-load-path)))

(add-to-list 'load-path "~/.emacs.d/site-lisp/org-mode/lisp")

;; Add melpa to package repos
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)

;; Keep emacs Custom-settings in separate file and load it on init
(setq custom-file (expand-file-name "custom-file.el" user-emacs-directory))
(load custom-file)

;; Add external projects to load path
(dolist (project (directory-files site-lisp-dir t "\\w+"))
  (when (file-directory-p project)
    (add-to-list 'load-path project)))

;; Write backup files to own directory
(setq backup-directory-alist
      `(("." . ,(expand-file-name
                 (concat user-emacs-directory "backups")))))

;; Make backups of files, even when they're in version control
(setq vc-make-backup-files t)

;; Setup exec path
;; (exec-path-from-shell-initialize)
(add-to-list 'exec-path "/usr/local/bin") ; Homebrew

;; Ask me to type y or n instead of yes or no.
(defalias 'yes-or-no-p 'y-or-n-p)

;; Disable audible bell.
(setq echo-keystrokes 0.1
      use-dialog-box nil
      visible-bell t
      ring-bell-function 'ignore)

;; Setup Cask
(defvar my/path-to-cask "/usr/local/share/emacs/site-lisp/cask")
(require 'cask (concat my/path-to-cask "/cask.el"))
(cask-initialize)

(defvar my/cask-dir (expand-file-name ".cask" user-emacs-directory))
(add-to-list 'load-path my/cask-dir)
(let ((default-directory my/cask-dir))
  (normal-top-level-add-subdirs-to-load-path))

(require 'use-package)
;;(eval-when-compile
;;  (require 'use-package))
(setq use-package-verbose t)
(require 'diminish)
(require 'bind-key)

(require 'pallet)
(pallet-mode t)

(use-package expand-region
  :defer 7
  :config
  (defun my/collapse-region ()
    (interactive)
    (er/expand-region -1))
  :bind (("C-=" . er/expand-region)
         ("C--" . my/collapse-region)))

(use-package vlf-setup
  :defer 5)

(use-package simple
  :demand t
  :init
  (setq-default indicate-empty-lines t)
  (setq delete-trailing-lines t)
  (setq x-select-enable-clipboard t)
  (setq-default indent-tabs-mode nil)
  (setq frame-title-format '(buffer-file-name "%f" ("%b")))
  (defun my/edit-init ()
    "Open Emacs init file."
    (interactive)
    (find-file "~/.emacs.d/init.el"))
  (defun my/edit-clojure-indents ()
    "Open Emacs init file."
    (interactive)
    (find-file "~/.emacs.d/settings/clojure-indentations.el"))
  (defun my/delete-other-window ()
    "Delete the OTHER window..."
    (interactive)
    (other-window 1)
    (delete-window))
  :config
  (when (not indicate-empty-lines)
    (toggle-indicate-empty-lines))
  (transient-mark-mode t)
  (add-hook 'after-change-major-mode-hook (lambda () (text-scale-set 1)))
  (column-number-mode 1)
  (blink-cursor-mode 0)
  (set-frame-font "Inconsolata 18" nil t)

  (defvar my/large-frame-width 1000) ;pixels
  (defvar my/large-frame-height 400)
  (defvar my/bad-math-offset 24
    "For some
    reason (- (display-pixel-width) (my/large-frame-width)) is
    slightly larger than the offset from the left side of the
    screen needs to be.")
  (defvar my/doc-size-offset 36)

  (defun my/single-display-workarea ()
    "Return the width of one display even in the presence of
    multiple monitors."
    (let* ((monitors (display-monitor-attributes-list))
           (monitor (car monitors)))
      (assoc 'workarea monitor)))

  (defun my/workarea-width (workarea)
    (nth 3 workarea))

  (defun my/workarea-height (workarea)
    (nth 4 workarea))

  (defun my/set-frame-size-and-position-to-something-reasonable ()
    "Set frame size and position.

  Attempt to place frame on the right side of the desktop and
  give a largish width if the desktop has a high enough
  resolution."
    (interactive)
    (if window-system
        (let* ((workarea (my/single-display-workarea))
               (workarea-width (my/workarea-width workarea))
               (workarea-height (my/workarea-height workarea))
               (frame-height (- workarea-height my/doc-size-offset))
               (left-offset (- workarea-width
                               my/large-frame-width
                               my/bad-math-offset)))
          (set-frame-width (selected-frame) my/large-frame-width nil t)
          (set-frame-height (selected-frame) frame-height nil t)
          ;; Position frame on the right side of the screen for optimal
          ;; web development workflow.
          (set-frame-position nil left-offset 0))))

  (my/set-frame-size-and-position-to-something-reasonable)

  (defun my/comment-or-uncomment-region-or-line ()
    "Comment or uncomment the region or the current line if there's no active region."
    (interactive)
    (let (beg end)
      (if (region-active-p)
          (setq beg (region-beginning) end (region-end))
        (setq beg (line-beginning-position) end (line-end-position)))
      (comment-or-uncomment-region beg end)))

  ;; http://stackoverflow.com/questions/8674912/how-to-collapse-whitespaces-in-a-region
  (defun my/just-one-space-in-region (beg end)
    "replace all whitespace in the region with single spaces"
    (interactive "r")
    (save-excursion
      (save-restriction
        (narrow-to-region beg end)
        (goto-char (point-min))
        (while (re-search-forward "\\s-+" nil t)
          (replace-match " ")))))

  :bind (("<f7>" . my/edit-init)
         ("<f8>" . my/edit-clojure-indents)
         ("M-#" . replace-string)
         ("C-c v" . eval-buffer)
         ("s-/" . my/comment-or-uncomment-region-or-line)
         ("C-]" . my/just-one-space-in-region)
         ("s-\\" . my/delete-other-window)))

(use-package linum
  :init (setq linum-format "%d  "))

(use-package files
  :init (setq mode-require-final-newline t)
  :config
  (add-hook 'before-save-hook
            (lambda ()
              (if (not indent-tabs-mode)
                  (untabify (point-min) (point-max)))
              (delete-trailing-whitespace))))

(use-package delsel
  :demand t
  :commands (delete-selection-mode)
  :config (delete-selection-mode t))

(use-package saveplace
  :demand t
  :init
  (setq-default save-place t)
  (setq save-place-file (expand-file-name ".places" user-emacs-directory)))

(use-package paren-face
  :config
  (show-paren-mode 1)
  (global-paren-face-mode 1))

(use-package sublime-themes
  ;; :disabled t
  :config
  ;; (load-theme 'white-sand t)
  ;; (load-theme 'wheatgrass t)
  ;; (load-theme 'brin t)
  ;; (load-theme 'hickey t)
  ;; (load-theme 'fogus t)
  ;; (load-theme 'graham t)
  ;; (load-theme 'granger t)
  ;; (load-theme 'odersky t)
  ;; (load-theme 'dorsey t)
  ;; (load-theme 'mccarthy t)
  ;; (load-theme 'wilson t)
  ;; (load-theme 'junio t)
  ;; (load-theme 'spolsky t)
  ;; (load-theme 'ritchie t)

  ;; Make highlighted region readable in themes with poor default
  ;; (set-face-attribute 'region nil :background "#666" :foreground "#ffffff")
  )

(use-package color-theme-sanityinc-tomorrow
  ;; :disabled t
  :config
  ;; (load-theme 'sanityinc-tomorrow-day t)
  ;; (load-theme 'sanityinc-tomorrow-night t)
  ;; (load-theme 'sanityinc-tomorrow-blue t)
  (load-theme 'sanityinc-tomorrow-bright t)
  ;; (load-theme 'sanityinc-tomorrow-eighties t)
  )

(use-package smex)

(use-package ivy
  :demand t
  :commands (ivy-mode)
  :bind (:map ivy-minibuffer-map
              ("C-x C-f" . my/ivy-dont-complete-me))
  :config

  (defun my/ivy-dont-complete-me () (substring "foo" 1)
         (interactive)
         (delete-minibuffer-contents)
         (insert (setq ivy--current
                       (if ivy--directory
                           (expand-file-name ivy-text ivy--directory)
                         ivy-text)))
         (setq ivy-exit 'done))

  (ivy-mode 1))

(use-package swiper
  :bind (("C-s" . swiper)))

(use-package counsel
  :bind (("C-x C-f" . counsel-find-file)
         ("C-c c f" . counsel-git)
         ("M-x"     . counsel-M-x)
         ("C-h f"   . counsel-describe-function)
         ("C-h v"   . counsel-describe-variable)))

(use-package aggressive-indent
  :defer 5
  :commands aggressive-indent-mode)

(use-package company
  :commands (global-company-mode)
  :defer 5
  :bind (:map company-active-map
              ("M-n" . nil)
              ("M-p" . nil)
              ("C-n" . company-select-next)
              ("C-p" . company-select-previous))
  :init
  (setq company-idle-delay 0.1)
  (setq company-minimum-prefix-length 1)
  (setq company-dabbrev-downcase nil)
  (add-hook 'after-init-hook 'global-company-mode)
  )

(use-package flycheck
  :defer 5
  :config
  (setq-default flycheck-emacs-lisp-load-path 'inherit)
  (setq-default flycheck-disabled-checkers
                (append flycheck-disabled-checkers
                        '(javascript-jshint
                          emacs-lisp-checkdoc)))
  (flycheck-add-mode 'javascript-eslint 'js2-mode)
  (setq-default flycheck-temp-prefix ".flycheck")
  (add-hook 'after-init-hook #'global-flycheck-mode))

;; (use-package flx-ido
;;   :commands (flx-ido-mode))

;; (use-package ido
;;   :demand t
;;   :config
;;   (ido-mode 1)
;;   (ido-everywhere 1)
;;   (flx-ido-mode 1)
;;   (setq ido-enable-flex-matching t)
;;   (setq ido-use-faces nil))

(use-package js2-mode
  :mode (("\\.js$"  . web-mode))
  :init

  ;; Indent body of js switch statement
  (setq js-switch-indent-offset 2)

  ;; Enable paredit in js modes
  ;; credit: https://truongtx.me/2014/02/22/emacs-using-paredit-with-non-lisp-mode
  (defun my/paredit-nonlisp ()
    "Turn on paredit mode for non-lisps."
    (interactive)
    (set (make-local-variable 'paredit-space-for-delimiter-predicates)
         '((lambda (endp delimiter) nil)))
    (paredit-mode 1))

  :config
  (add-hook 'js-mode-hook (lambda ()
                            ;; (aggressive-indent-mode 1)
                            (my/paredit-nonlisp)))

  (add-hook 'json-mode-hook (lambda () (setq js-indent-level 2)))
  (setq js2-basic-offset 2)
  (setq js-indent-level 2)
  (setq js2-strict-trailing-comma-warning nil)
  (setq js2-global-externs '("expect" "require")))

(use-package lisp-mode
  :mode "\\.wast\\'")

(use-package paredit
  :config (add-hook 'emacs-lisp-mode-hook (lambda () (paredit-mode 1))))

(use-package projectile
  :init (setq projectile-completion-system 'ivy)
  :bind (("C-c p f" . projectile-find-file)
         ("C-c p l" . projectile-find-file-in-directory)
         ("C-c p g" . projectile-grep))
  :config
  (projectile-global-mode))

(use-package css-mode
  :mode (("\\.css\\'"  . css-mode)
         ("\\.scss\\'" . css-mode)
         ("\\.less\\'" . css-mode))
  :init
  (defvar my/sass-search-dir "../../node_modules")

  (defun my/sass-underscore-prefix (path)
    "Add an underscore to the last element of PATH delimeted by
path separators and append .scss extension."
    (letrec ((path-parts (split-string path "/"))
             (dir-root (mapconcat 'identity (butlast path-parts) "/")))
      (concat dir-root
              (if (string-blank-p dir-root) "" "/")
              "_"
              (car (last path-parts))
              ".scss")))

  (defun my/sass-find-local-import ()
    "Find sass file implied by the import statement at point relative to local directory."
    (interactive)
    (save-excursion
      (search-backward "\"")
      (find-file (my/sass-underscore-prefix (sexp-at-point)))))

  ;; TODO: pull out my project specific params
  (defun my/goto-import-at-point ()
    "Find sass file at point accounting for the prefix naming conventions required by sass."
    (interactive)
    (save-excursion
      (search-backward "\"")
      (letrec ((lib-path (sexp-at-point))
               ;; (path-parts (split-string lib-path "/"))
               (resolved-path (concat my/sass-search-dir "/"
                                      (my/sass-underscore-prefix lib-path))))
        (find-file resolved-path))))

  :bind (("C-c i" . my/goto-import-at-point)
         ("C-c l" . my/sass-find-local-import)))

(use-package web-mode
  :commands (web-mode)
  :mode (("\\.html$" . web-mode)
         ("\\.jsx$"  . web-mode)
         ;; Uncomment when working with JSX in files with .js extension
         ;; ("\\.js$"  . web-mode)
         )
  :init
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-enable-current-element-highlight t)
  :config

  (defun eslint-fix-file ()
    (interactive)
    (message "eslint --fixing the file" (buffer-file-name))
    (shell-command (concat "eslint --fix " (buffer-file-name))))

  (defun eslint-fix-file-and-revert ()
    (interactive)
    (eslint-fix-file)
    (revert-buffer t t))

  ;; TODO: Make this only fire for web-mode buffers
  ;; Add this hook to run eslint --fix on save
  ;; (add-hook 'web-mode-hook
  ;;           (lambda ()
  ;;             (add-hook 'after-save-hook (lambda ()
  ;;                                          (eslint-fix-file-and-revert)
  ;;                                          ;; (if (eq major-mode "web-mode")
  ;;                                          ;;     (eslint-fix-file-and-revert))
  ;;                                          ))))

  (add-to-list #'web-mode-content-types
               '("jsx" . "\\.js[x]?\\'"))

  (defadvice web-mode-highlight-part (around tweak-jsx activate)
    (if (equal web-mode-content-type "jsx")
        (let ((web-mode-enable-part-face nil))
          ad-do-it)
      ad-do-it)))

(use-package dash)
(use-package dash-functional)

(use-package ido
  :commands ido-completing-read)

(use-package cider
  :commands cider-mode
  :init
  (defvar cider-component-reset-fn nil)

  (defun my/reloaded-reset ()
    (interactive)
    (with-current-buffer "*cider-repl sizr*"
      (insert "(reset)")
      (cider-repl-return)))

  (defun cider-set-component-reset-fn-from-ns (fn-name)
    "Pickup the ns from the current ns, remember it, and set the reset
function to the one specified by user."
    (interactive "MReset thunk: ")
    (make-local-variable 'cider-component-reset-fn)
    (setq cider-component-reset-fn fn-name))

  (defun cider-component-reset-system ()
    "Refresh change code and reset the component system."
    (interactive)
    (cider-interactive-eval "(dbad/reset)"))

  :config (add-hook 'cider-repl-mode-hook (lambda () (paredit-mode 1)))

  :bind (("C-c M-j" . cider-jack-in)
         ;; ("C-c k" . cider-repl-clear-buffer)
         ;; ("C-c c r" . cider-component-reset-system)
         ("C-c c r" . my/reloaded-reset)))

(use-package clojure-mode
  :defer t
  :mode (("\\.clj$" . clojure-mode)
         ("\\.cljs$" . clojurescript-mode)
         ("\\.cljc$" . clojure-mode)
         ("\\.boot$" . clojure-mode))

  :config
  (use-package clojure-indentations
    :defines my/clojure-indentations
    :config
    (dolist (item my/clojure-indentations)
      (put-clojure-indent (car item) (cdr item))))

  (add-hook 'clojure-mode-hook
            (lambda ()
              (paredit-mode 1)
              (cider-mode 1))))

(use-package css-mode
  :defer t
  :init (setq css-indent-offset 4))

(use-package groovy-mode
  :commands (groovy-mode)
  :mode ("\\.gradle$" . groovy-mode))

(use-package json-mode
  :commands (json-mode)
  :mode ("\\.json$" . json-mode))

(use-package demo-it)

;; (use-package org-tree-slide)

(use-package elnode
  :defer t
  :bind (("C-c C-e w" . elnode-make-webserver)
         ("C-c C-e l" . elnode-server-list)
         ("C-c C-e k" . elnode-stop)))

;; (global-set-key (kbd "<f10>") 'org-tree-slide-mode)
;; (global-set-key (kbd "s-<f10>") 'org-tree-slide-skip-done-toggle)

(use-package inf-clojure
  :defer t
  :config
  (setq inf-clojure-project-root-files '("project.clj" "build.boot" "src"))
  (setq inf-clojure-program "planck -c src/main:src/test"))

(use-package magit
  :defer t
  :bind (("C-c g" . magit-status))
  :config
  (require 'fullframe)
  (fullframe magit-status magit-mode-quit-window))

(use-package multiple-cursors
  :defer t
  :bind (("C-s-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-next-like-this)
         ("C-c M-<" . mc/mark-all-like-this)))

(use-package neotree
  :defer t
  :disabled t
  :config
  (setq neo-theme 'ascii)
  (setq neo-window-width 55)
  :bind (("<f11>" . neotree-toggle)))

(use-package org
  :defer t
  :config
  (use-package ob-clojure
    ;; :init (setq org-babel-clojure-backend 'cider)
    )
  (use-package ob-sh)
  (use-package ob-js)
  (use-package org-bullets
    :commands org-bullets-mode)

  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

  ;; Open directory links in emacs instead of the OS file browser
  (add-to-list #'org-file-apps '(directory . emacs))

  :bind (:map org-mode-map
         ("s-i"   . org-indent-block)))

(use-package s)

(use-package eshell
  :defer 10
  :bind (("C-c k" . eshell/clear))
  :config
  (defun eshell/clear ()
    "Clear eshell output buffer."
    (interactive)
    (let ((inhibit-read-only t))
      (erase-buffer)
      (eshell-send-input)))

  (defun my/complement (f)
    (lambda (&rest args)
      (not (apply f args))))

  (defun my/bash-exports (bash-str)
    "Parse simple bash expression and interpret export statements
with eshell set-env."
    (interactive)
    (let* ((commentp (-partial 'string-prefix-p "#"))
           (exportp (-partial 'string-prefix-p "export "))
           (export-to-list (lambda (s)
                             (cdr
                              (s-match
                               "export \\([A-Za-z_]+\\)=\"\\([A-Za-z0-9\./:]+\\)\""
                               s))))
           (lines (-filter (my/complement commentp) (split-string bash-str "\n")))
           (exports (-map export-to-list (-filter exportp lines))))
      exports))

  (defun my/bash-eval (bash-str)
    "Parse simple bash expression and interpret export statements
with eshell set-env."
    (interactive)
    (dolist (export (my/bash-exports bash-str))
      (apply 'exec-path-from-shell-setenv export)
      (apply 'setenv export)))

  (defun my/point-docker-to-minikube ()
    (my/bash-eval (shell-command-to-string "minikube docker-env")))

  (add-hook 'eshell-mode-hook (lambda () (exec-path-from-shell-initialize)))
  (add-hook 'shell-mode-hook (lambda () (company-mode -1))))

(use-package shell
  :config
  (add-hook 'shell-mode-hook (lambda () (exec-path-from-shell-initialize)))
  (add-hook 'shell-mode-hook (lambda () (company-mode -1))))

;;; Snippets
(use-package yasnippet
  :defer 5
  :commands (yas-global-mode yas-expand)
  :config
  (yas-global-mode 1)
  (define-key yas-minor-mode-map (kbd "TAB") nil)
  :bind (:map yas-minor-mode-map
              ("M-TAB" . yas-expand)))

(use-package tramp
  :defer t
  :config
  (setq tramp-default-method "ssh")

  ;; Tell
  (defun my/tramp-file-advice (orig &rest args)
    (let ((temporary-file-directory "/tmp"))
      (apply orig args)))

  (advice-add 'org-babel-temp-file :around #'my/tramp-file-advice))

(use-package shell
  :init
  ;; http://stackoverflow.com/questions/7733668/command-to-clear-shell-while-using-emacs-shell
  (defun my/shell-clear ()
    (interactive)
    (let ((comint-buffer-maximum-size 0))
      (comint-truncate-buffer)))
  :bind (("C-c s c" . my/shell-clear)))

(use-package simple-httpd
  :defer 20
  :commands (httpd-start httpd-stop httpd-serve-directory)
  :init (setq httpd-port 7000))

(use-package redux)

(use-package evil)

;; Setup shell environment
(use-package exec-path-from-shell
  ;; :defer t
  :commands (exec-path-from-shell-initialize)
  :config
  (exec-path-from-shell-initialize))

;; (use-package timonier
;;   :commands (timonier-k8s)
;;   :bind (("C-c K t" . timonier-k8s))
;;   :init (setq timonier-k8s-proxy "http://127.0.0.1:8001"))

(use-package yaml-mode
  :defer 30)

;; Project and work-specific config that I don't want to check into git
(when (locate-library "unpublished-settings")
  (require 'unpublished-settings))

(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'erase-buffer 'disabled nil)
;;; init.el ends here
