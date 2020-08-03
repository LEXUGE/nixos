;;; package --- Main init file
;;; Commentary:
;;; This is my init file

;;; Code:

(add-to-list 'load-path (concat user-emacs-directory "elisp"))

(require 'base)
(require 'base-theme)

(require 'ext-completion)
(require 'ext-system)
(require 'ext-edit)
(require 'ext-git)
(require 'ext-org)
(require 'ext-tex)

(require 'base-functions)
(require 'base-global-keys)

(require 'lang-nix)

(require 'lang-markdown)

(require 'lang-python)

(require 'lang-web)

(require 'lang-haskell)

(require 'lang-rust)

(require 'lang-c)
