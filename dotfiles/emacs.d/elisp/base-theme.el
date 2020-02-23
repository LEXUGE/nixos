(use-package doom-themes
  :defer t
  :init
  (load-theme 'doom-one t))

; Use doom-modeline
(use-package doom-modeline
  :init (doom-modeline-mode 1))

(provide 'base-theme)
