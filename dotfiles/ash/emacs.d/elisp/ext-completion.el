;; Completion tools

;; Setup ivy-powered emacs commands counterparts
(use-package counsel
  :bind
  ("M-x" . counsel-M-x)
  ("C-x C-m" . counsel-M-x)
  ("C-x C-f" . counsel-find-file))

(use-package ivy
  :bind
  ("C-x C-r" . ivy-resume)
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers nil)
  (setq ivy-use-selectable-prompt t)
  (define-key read-expression-map (kbd "C-r") 'counsel-expression-history))

(use-package company
  :config
  (add-hook 'after-init-hook 'global-company-mode)
  :custom
  (company-idle-delay 0.0 "Complete instantly"))

(provide 'ext-completion)
