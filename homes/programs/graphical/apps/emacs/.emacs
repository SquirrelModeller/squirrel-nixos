;; Basic Emacs settings
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(electric-pair-mode 1)
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)
(set-face-attribute 'default nil :height 130)

(setq make-backup-files nil)
;;(setq backup-directory-alist `(("." . "~/.emacs.d/backups")))
(setq auto-save-default nil)

(windmove-default-keybindings)

;; Initialize package sources
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

;; Use-package initialization
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

;; Custom theme setup
(add-to-list 'custom-theme-load-path "~/.config/emacs/themes/")
(load-theme 'my-kitty t)

(use-package neotree
  :ensure t
  :bind ([f8] . neotree-toggle))

(setq neo-theme (if (display-graphic-p) 'icons 'arrow))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(neo-dir-link-face ((t (:foreground "#FF9D64"))))
 '(neo-expand-btn-face ((t (:foreground "#FF9D64"))))
 '(neo-file-link-face ((t (:foreground "#FFFFFF"))))
 '(neo-root-dir-face ((t (:foreground "#FF9D64" :weight bold)))))
 ;; Expand button in orange

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-banner-logo-title "Welcome Squirrel"
	dashboard-vertically-center-content t
	dashboard-center-content t
	dashboard-set-heading-icons t
	dashboard-set-file-icons t
	dashboard-icon-type 'icons
	dashboard-startup-banner "~/Desktop/Files/Personal Files/Pictures/Logo/SquirrelLogo.png"
	))

(use-package elscreen
  :ensure t
  :config
  (elscreen-start))

(use-package rainbow-mode
  :ensure t
  :hook ((prog-mode . rainbow-mode)
	 (conf-mode . rainbow-mode)
	 (css-mode . rainbow-mode)
	 (html-mode . rainbow-mode)
	 (text-mode . rainbow-mode))
  :config
  (setq rainbow-x-colors t
        rainbow-html-colors t
        rainbow-latex-colors t
        rainbow-r-colors t
        rainbow-ansi-colors t
        rainbow-escape-sequences t))

(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
	 ("C->" . mc/mark-next-like-this)
	 ("C-<" . mc/mark-previous-like-this)
	 ("C-c C-<" . mc/mark-all-like-this)))

(use-package workgroups2
  :ensure t
  :config
  (workgroups-mode 1)
  (setq wg-session-file "~/.emacs.d/.emacs_workgroups"
        wg-emacs-exit-save-behavior 'save
        wg-workgroups-mode-exit-save-behavior 'save
        wg-mode-line-display-on t
        wg-flag-modified t)
  (global-set-key (kbd "C-c w c") 'wg-create-workgroup)
  (global-set-key (kbd "C-c w k") 'wg-kill-workgroup)
  (global-set-key (kbd "C-c w s") 'wg-switch-to-workgroup)
  (global-set-key (kbd "C-c w r") 'wg-rename-workgroup))

(use-package minimap
  :ensure t
  :bind (("C-c m" . minimap-mode))
  :config
  (setq minimap-window-location 'right)
  (custom-set-faces
   '(minimap-active-region-background
     ((((background dark)) (:background "#3e3e3e"))
      (((background light)) (:background "#d0d0d0"))
      (t (:background "#3e3e3e")))))
  )

;; Company-mode for autocompletion
(use-package company
  :ensure t
  :hook (after-init . global-company-mode)
  :config
  (setq company-idle-delay 0.2
        company-minimum-prefix-length 1
        company-selection-wrap-around t
        company-tooltip-align-annotations t)
  (define-key company-active-map (kbd "TAB") 'company-complete-selection)
  (define-key company-active-map (kbd "C-n") 'company-select-next)
  (define-key company-active-map (kbd "C-p") 'company-select-previous))

(use-package qml-mode
  :ensure t
  :mode "\\.qml\\'"
  :config
  ;(setq qml-indent-offset 4)
  )

(use-package flycheck
  :ensure t
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode))

(use-package nix-mode
  :ensure t
  :mode "\\.nix\\'")

(use-package format-all
  :commands format-all-mode
  :hook ((prog-mode . format-all-ensure-formatter)
         (before-save . format-all-buffer))
  :config
  (setq format-all-show-errors 'warnings))

(with-eval-after-load 'format-all
  (setq-default format-all-formatters '((nix-mode alejandra))))

(add-hook 'nix-mode-hook #'format-all-mode)

(setq-default format-all-formatters '((nix-mode nixpkgs-fmt)))


(global-set-key (kbd "C-l") 'forward-char)
(global-set-key (kbd "C-h") 'backward-char)
(global-set-key (kbd "C-k") 'previous-line)
(global-set-key (kbd "C-j") 'next-line)
(global-set-key (kbd "M-l") 'forward-word)
(global-set-key (kbd "M-h") 'backward-word)
(global-set-key (kbd "C-c l") 'recenter-top-bottom)
(global-set-key (kbd "C-c k") 'kill-line)
(global-set-key (quote [M-down]) (quote scroll-up-line))
(global-set-key (quote [M-up]) (quote scroll-down-line))

(defun wl-copy (text)
  (let ((p (make-process :name "wl-copy"
                         :command '("wl-copy")
                         :connection-type 'pipe)))
    (process-send-string p text)
    (process-send-eof p)))
(setq interprogram-cut-function 'wl-copy)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(flycheck qml-mode all-the-icons workgroups2 multiple-cursors rainbow-mode elscreen dashboard wc-mode projectile neotree company autothemer)))

