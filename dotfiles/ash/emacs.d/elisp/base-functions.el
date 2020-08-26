;; Add your custom functions here

;; (defun something
;;    (do-something))

(defun enable-trailing-whitespace ()
  "Show trailing spaces and delete on saving."
  (setq show-trailing-whitespace t)
  (add-hook 'before-save-hook #'delete-trailing-whitespace nil t))

(provide 'base-functions)
