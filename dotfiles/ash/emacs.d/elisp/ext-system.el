;; Basic stuff that makes a functional emacs

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
  :ensure nil
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
  :ensure nil
  :bind
  ("C-s-p" . windmove-up)
  ("C-s-n" . windmove-down)
  ("C-s-b" . windmove-left)
  ("C-s-f" . windmove-right))

(use-package flycheck
  :ensure nil
  :init (global-flycheck-mode))

;; Recent files
(use-package recentf
  :ensure nil
  :hook (after-init . recentf-mode)
  :init (setq recentf-max-saved-items 300
              recentf-exclude
              '("\\.?cache" ".cask" "url" "COMMIT_EDITMSG\\'" "bookmarks"
                "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
                "\\.?ido\\.last$" "\\.revive$" "/G?TAGS$" "/.elfeed/"
                "^/tmp/" "^/var/folders/.+$" ; "^/ssh:"
                (lambda (file) (file-in-directory-p file package-user-dir))))
  :config
  (setq recentf-save-file (recentf-expand-file-name "~/.emacs.d/private/cache/recentf"))
  (setq recentf-auto-cleanup 'never) ; Don't conflict with tramp!
  (push (expand-file-name recentf-save-file) recentf-exclude))

;; (use-package vterm)

(provide 'ext-system)
