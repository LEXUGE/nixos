;; Basic stuff that makes a functional emacs

;; Emacs dashboard
(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-center-content t)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t))

;; Ensure environment variables inside Emacs look the same as in the user's shell.
(use-package exec-path-from-shell
  :config
  (when (memq window-system '(mac ns))
    (exec-path-from-shell-initialize)))

;; Highlight current line number
(use-package hlinum
  :config
  (hlinum-activate))

;; Better numbering
(use-package linum
  :config
  (setq linum-format " %3d ")
  :hook (prog-mode . display-line-numbers-mode))

;; Tree format file management
(use-package neotree
  :config
  (setq neo-theme 'icons
        neotree-smart-optn t
        neo-window-fixed-size nil)
  :bind ("C-x t" . neotree-toggle))

;; Display a line instead of "^L"
(use-package page-break-lines)

;; Expand available key options
(use-package which-key
  :config
  (which-key-mode))

;; Move around windows fast
(use-package windmove
  :bind
  ("C-s-p" . windmove-up)
  ("C-s-n" . windmove-down)
  ("C-s-b" . windmove-left)
  ("C-s-f" . windmove-right))

(use-package flycheck
  :init (global-flycheck-mode))

;; Recent files
(use-package recentf
  :config
  (setq recentf-save-file (recentf-expand-file-name "~/.emacs.d/private/cache/recentf"))
  (setq recentf-auto-cleanup 'never) ; Don't conflict with tramp!
  (recentf-mode 1))

;; (use-package vterm)

;; Automatically update packages installed
(use-package auto-package-update
  :config
  (auto-package-update-maybe)
  :custom
  (auto-package-update-delete-old-versions t "Delete the old versions if present on update")
  (auto-package-update-hide-results t "Don't show results of the update")
  (auto-package-update-prompt-before-update t "Prompt before update"))

(provide 'ext-system)
