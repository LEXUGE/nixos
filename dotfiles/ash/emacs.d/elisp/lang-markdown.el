(use-package markdown-mode
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown")
  :config
  (remove-hook 'markdown-mode-hook #'enable-trailing-whitespace)
  (remove-hook 'gfm-mode-hook #'enable-trailing-whitespace))

(provide 'lang-markdown)
