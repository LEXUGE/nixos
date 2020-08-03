;; Ivy and other completion tools

(use-package counsel
  :bind
  ("M-x" . counsel-M-x)
  ("C-x C-m" . counsel-M-x)
  ("C-x C-f" . counsel-find-file)
  ("C-x c k" . counsel-yank-pop))

(use-package ivy
  :bind
  ("C-x s" . swiper)
  ("C-x C-r" . ivy-resume)
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers nil)
  (setq ivy-use-selectable-prompt t)
  (define-key read-expression-map (kbd "C-r") 'counsel-expression-history))

(use-package company
  :config
  (add-hook 'after-init-hook 'global-company-mode))

(provide 'ext-completion)
