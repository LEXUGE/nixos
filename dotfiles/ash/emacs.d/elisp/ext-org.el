;; Org-mode

(use-package org
  :config
  (setq org-directory "~/org-files"
        org-default-notes-file (concat org-directory "/todo.org"))
  (setq org-startup-indented t)
  (setq TeX-auto-untabify 't) ;; Convert tabs properly into PDF
  (setq org-latex-toc-command "\\tableofcontents \\clearpage") ;; Force page break after TOC
  :hook (org-mode . org-cdlatex-mode)
        (org-mode . visual-line-mode)
  :bind
  ("C-c l" . org-store-link)
  ("C-c a" . org-agenda))

(use-package org-bullets
  :config
  (setq org-hide-leading-stars t)
  (add-hook 'org-mode-hook
            (lambda ()
              (org-bullets-mode t))))

(provide 'ext-org)
