(use-package doom-themes
  :defer t
  :init
  (load-theme 'doom-one t))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(provide 'base-theme)
