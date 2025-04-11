;; -*- lexical-binding: t -*-

(use-package slime
  :defer t
  :after lisp-mode
  :config
  (setq-default inferior-lisp-program "@sbcl@")
  (slime-setup '(slime-fancy slime-company slime-trace-dialog slime-xref-browser))

  (defun squircle-space-after-slime-show-description (&rest rest)
    ;; Slime defaults to fundamental mode when showing docs.  This is
    ;; a little annoying because slime-company has a nice mode for
    ;; showing the exact same text.  Let's just use their mode!
    (let ((name (slime-buffer-name :description)))
      (with-current-buffer name
        (when (eql major-mode 'fundamental-mode)
          (slime-company-doc-mode)))))
  (advice-add 'slime-show-description :after 'squircle-space-after-slime-show-description))

(use-package company
  :after lisp-mode
  :hook ((lisp-mode . company-mode)
         (slime-repl-mode . company-mode)))

(use-package smartparens
  :after lisp-mode
  :hook ((lisp-mode . smartparens-mode)
         (slime-repl-mode . smartparens-mode))
  :config
  (require 'smartparens-config))

(use-package vertico
  :config (vertico-mode)
  :demand t)

(use-package marginalia
  :config (marginalia-mode)
  :demand t)

(use-package doom-themes
  :config
  (add-hook 'after-init-hook (lambda ()
                               (unless custom-enabled-themes
                                 (load-theme 'doom-bluloco-dark t)))))

(tool-bar-mode -1)

(which-key-mode 1)
