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
  ("C-x b" . ivy-switch-buffer)
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers nil)
  (setq ivy-use-selectable-prompt t)
  (define-key read-expression-map (kbd "C-r") 'counsel-expression-history))

(use-package company
  :hook (after-init . global-company-mode)
  :custom
  (company-idle-delay 0.0 "Complete instantly")
  ;; Use standard C-n, C-p for company candidates selection
  :bind
  (:map company-active-map
	("C-n" . company-select-next)
	("C-p" . 'company-select-previous)))

(provide 'ext-completion)
