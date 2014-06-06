;; Load subdirectories and single file packages
(let ((default-directory "~/.emacs.d/"))
  (normal-top-level-add-to-load-path '("."))
  (normal-top-level-add-subdirs-to-load-path))
  (normal-top-level-add-to-load-path '("smart-tab.el" "gold-ratio-scroll-screen.el" "auto-complete.el"))

;; Specify emacs package using package manager
(require 'package)
(dolist (source '(("marmalade" . "http://marmalade-repo.org/packages/")
                  ("melpa" . "http://melpa.milkbox.net/packages/")))
  (add-to-list 'package-archives source t))
(package-initialize)

;; Emacs package manager - checks for the following packages and installs them automatically
(when (not package-archive-contents)
  (package-refresh-contents))
(defvar src/packages
  '(js2-mode ac-js2 js2-refactor))
(dolist (p src/packages)
  (when (not (package-installed-p p))
    (package-install p)))

;; autocomplete
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(set-default 'ac-sources
             '(ac-source-abbrev
               ac-source-dictionary
               ac-source-words-in-buffer
               ac-source-words-in-same-mode-buffers
               ac-source-semantic))
(ac-config-default)
(dolist (m '(java-mode))
  (add-to-list 'ac-modes m))
(global-auto-complete-mode t)


(require 'highlight-parentheses)
(require 'tramp)

;;(add-to-list 'load-path  "~/.emacs.d/smart-tab.el")
(require 'smart-tab)

;;(add-to-list 'load-path "~/.emacs.d/company")
(autoload 'company-mode "company" nil t)
;; Gold-ratio-scroll-screen Scroll half screen down or up, and highlight current line
;;(add-to-list 'load-path "~/.emacs.d/gold-ratio-scroll-screen.el")
(autoload 'gold-ratio-scroll-screen-down "gold-ratio-scroll-screen" "scroll half screen down" t)
(autoload 'gold-ratio-scroll-screen-up "gold-ratio-scroll-screen" "scroll half screen up" t)
(global-set-key "\C-v" 'gold-ratio-scroll-screen-down)
(global-set-key "\M-v" 'gold-ratio-scroll-screen-up)

;; navigation window
;;(add-to-list 'load-path "~/.emacs.d/emacs-nav-49/")
(require 'nav)
(nav-disable-overeager-window-splitting)

(require 'js2-mode)
;;(require 'js2-refactor)
;; js2 mode
(autoload 'js2-mode "js2" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.json$" . js2-mode))
(add-hook 'js2-mode-hook 'js2-minor-mode) ;; use apropos-command to list js2 options
(add-hook 'js2-mode-hook 'ac-js2-mode)
;;(add-hook 'js2-mode-hook 'js2-refactor)


;; set modes here
;; Optional: set up a quick key to toggle nav
;; (global-set-key [f8] 'nav-toggle)
(global-smart-tab-mode 1)
(column-number-mode t)
(highlight-parentheses-mode t)
(ido-mode t)
(global-linum-mode t)
;;(global-whitespace-mode t)
(delete-selection-mode t)
(global-visual-line-mode t)

;; C Mode
(setq c-indent-level 2)

;; JS indent
(setq js2-highlight-level 3)
(setq js2-indent-level 2)
(setq-default indent-tabs-mode nil)
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(tab-stop-list (quote (2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 64 66 68 70 72 74 76 78 80 82 84 86 88 90 92))))


;; Java indent
(add-hook 'java-mode-hook (lambda ()
                            (setq c-basic-offset 8
                                   tab-width 8
                                   indent-tabs-mode t)))

;Skip comments and blank lines
(defun python-skip-comments/blanks (&optional backward))
(set-default 'tramp-default-proxies-alist (quote ((".*" "\\`root\\'" "/ssh:%h:"))))
(setq tramp-default-method "ssh")

;; Change back directory and other back up settings
(setq backup-by-copying-when-linked t)
(setq backup-directory-alist '(("."."~/.saves/")))
(setq delete-old-versions t
  kept-new-versions 6
  kept-old-versions 2
  version-control t)
; Save windows configuration
;(insert (prin1-to-string (current-window-configuration-printable)))

; restore windows configuration
;(restore-window-configuration (read (current-buffer)))
; change commands for switching between windows
(global-set-key (kbd "C-x <up>") 'windmove-up)
(global-set-key (kbd "C-x <left>") 'windmove-left)
(global-set-key (kbd "C-x <right>") 'windmove-right)
(global-set-key (kbd "C-x <down>") 'windmove-down)

;; Add jslint
(when (load "flymake" t)
  (defun flymake-jslint-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "jslint" (list "--terse" local-file))))
  
  (setq flymake-err-line-patterns
        (cons '("^\\(.*\\)(\\([[:digit:]]+\\)):\\(.*\\)$"
                1 2 nil 3)
              flymake-err-line-patterns))
  
  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.js\\'" flymake-jslint-init))
  
  (require 'flymake-cursor)
  )

(add-hook 'js2-mode-hook
          (lambda ()
            (flymake-mode 1)
            (define-key js2-mode-map "\C-c\C-n" 'flymake-goto-next-error)))
