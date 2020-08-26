(use-package vscode-dark-plus-theme
  :config
  (load-theme 'vscode-dark-plus t))

;; Use doom-modeline
(use-package mood-line
  :config (mood-line-mode))

;; install all-the-icons
(use-package all-the-icons)

;; Emacs dashboard
(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-center-content t)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-footer-messages '("Never drink to a success before it happens. Not very scientific, but good advice. -- For All Mankind")))

(provide 'base-theme)
