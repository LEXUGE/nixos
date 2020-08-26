;;; Harry Ying's emacs configuration
;;; Commentary:
;;; This is my init file

;;; Code:

(add-to-list 'load-path (concat user-emacs-directory "elisp"))

(require 'base)
(require 'base-theme)
(require 'base-functions)
(require 'base-global-keys)

(require 'ext-completion)
(require 'ext-system)
(require 'ext-edit)
(require 'ext-git)
(require 'ext-org)
(require 'ext-tex)

(require 'lang-nix)
(require 'lang-haskell)
(require 'lang-markdown)
