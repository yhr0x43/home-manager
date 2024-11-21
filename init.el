(setq-default inhibit-startup-screen t
	      tab-width 8
	      indent-tabs-mode t)
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 1)
(column-number-mode 1)

;; transparency
(set-frame-parameter nil 'alpha-background 70)
(add-to-list 'default-frame-alist '(alpha-background . 70))


(set-face-attribute 'default nil :height 130)

;; backup file
(setq backup-by-copying t
      backup-directory-alist `(("." . "~/.local/share/emacs/backup"))
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

;;; multiple-cursors
(require 'multiple-cursors)
(keymap-global-set "C-<return>" 'mc/edit-lines)
(keymap-global-set "C->" 'mc/mark-next-like-this)
(keymap-global-set "C-<" 'mc/mark-previous-like-this)

;;; c-mode
(setq-default c-basic-offset 2
	      c-default-style '((java-mode . "java")
				(awk-mode . "awk")
				(other . "bsd")))

(keymap-global-set "<f5>" 'compile)

(with-eval-after-load 'default-text-scale
  (default-text-scale-mode nil))

(with-eval-after-load 'nix-mode
  (add-hook 'auto-mode-alist '("\\.nix\\'" . nix-mode)))
  
(with-eval-after-load 'rainbow-delimiters
  (add-hook 'emacs-lisp-mode-hook #'rainbow-delimiters-mode))

(global-set-key (kbd "C-,") 'duplicate-line)
(global-set-key (kbd "C-.") 'copy-from-above-command)

(defun rc/display-fill-column ()
  (display-fill-column-indicator-mode t))
(add-hook 'c-mode-hook 'rc/display-fill-column)

(require 'fasm-mode)

;; TeX view program
(add-hook 'LaTeX-mode-hook
  (lambda () (add-to-list 'TeX-view-program-selection '(output-pdf "Zathura"))))

;; load this after everything else per recommendation by the author
;; https://github.com/purcell/envrc#usage
(with-eval-after-load 'envrc
  (envrc-global-mode))

(custom-set-variables
 '(custom-enabled-themes '(tango-dark))
 '(display-line-numbers 'relative)
 '(inhibit-startup-screen t)
 '(font-latex-fontify-script nil))

(custom-set-faces
 )
