;; pyim - Emacs-based Chinese Input Method

(use-package pyim
  :config
  ;; Activate basedict vocabulary list
  (use-package pyim-basedict
    :ensure nil
    :config (pyim-basedict-enable))

  ;; Install posframe
  (use-package posframe)

  (setq default-input-method "pyim")

  (setq pyim-default-scheme 'quanpin)

  (setq-default pyim-english-input-switch-functions
                '(pyim-probe-isearch-mode ; Pinyin search
		  pyim-probe-dynamic-english ; automatically switch between pinyin and English
                  pyim-probe-program-mode ; Only enable pinyin in comment if the buffer is derived from prog-mode
                  pyim-probe-org-structure-template))

  (setq-default pyim-punctuation-half-width-functions
                '(pyim-probe-punctuation-line-beginning
                  pyim-probe-punctuation-after-punctuation))

  ;; Enable pinyin search functionality.
  (pyim-isearch-mode 1)

  ;; Use posframe to draw pop-up sheets.
  (setq pyim-page-tooltip 'posframe)

  ;; Five candidates at most
  (setq pyim-page-length 5)

  :bind
  (("M-j" . pyim-convert-string-at-point)
   ("C-;" . pyim-delete-word-from-personal-buffer)))

(provide 'ext-pyim)
