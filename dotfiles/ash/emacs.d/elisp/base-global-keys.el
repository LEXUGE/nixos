;; Add your keys here, as such

;; (define-key [KEYMAP] (kbd "[SHORTCUT]") '[FUNCTION])
;; (global-set-key (kbd "[SHORTCUT]") '[FUNCTION])

;; Use standard C-n, C-p for company candidates selection
(define-key company-active-map (kbd "C-n") 'company-select-next)
(define-key company-active-map (kbd "C-p") 'company-select-previous)

(global-set-key (kbd "C-c C-s") 'find-grep-dired) ; use grep to find content in a folder recursively

(provide 'base-global-keys)
