;; Extensions that enhance the edit experience

;; Expand region increases the selected region by semantic units
(use-package expand-region
  :bind
  ("C-=" . er/expand-region))

(use-package avy
  :bind
  ("C-c SPC" . avy-goto-char))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package undo-tree
  :config
  ;; Remember undo history
  (setq
   undo-tree-auto-save-history nil
   undo-tree-history-directory-alist `(("." . ,(concat temp-dir "/undo/"))))
  (global-undo-tree-mode 1))

(use-package multiple-cursors
  :bind
  ("C-S-c C-S-c" . mc/edit-lines)
  ("C->" . mc/mark-next-like-this)
  ("C-<" . mc/mark-previous-like-this)
  ("C-c C->" . mc/mark-all-like-this))

(use-package browse-kill-ring
  :config
  (browse-kill-ring-default-keybindings)
  (setq browse-kill-ring-highlight-current-entry t))

;; On-the-fly spell checker
(use-package flyspell
  :if (executable-find "hunspell")
  :hook (((text-mode org-mode) . flyspell-mode)
         (haskell-mode . flyspell-prog-mode)
         )
  :init
  (setq ispell-program-name "hunspell")
  (setq ispell-local-dictionary "en_US")
  (setq ispell-local-dictionary-alist
        '(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_US") nil utf-8)))
  (setq ispell-hunspell-dictionary-alist ispell-local-dictionary-alist))

(use-package flyspell-correct-ivy
  :after flyspell
  :bind ("C-c n" .  flyspell-correct-wrapper)
  :init
  (setq flyspell-correct-interface #'flyspell-correct-ivy))

(provide 'ext-edit)
