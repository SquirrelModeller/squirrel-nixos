(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(add-to-list 'custom-theme-load-path
             (file-name-concat user-emacs-directory "themes"))
(when (file-exists-p custom-file)
  (load custom-file nil t))

(setq package-enable-at-startup nil)

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

(setq frame-inhibit-implied-resize t)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-splash-screen t)
(setq use-dialog-box nil)

(setq gc-cons-threshold most-positive-fixnum)
(setq gc-cons-percentage 0.6)

(load-file (expand-file-name "config.el" user-emacs-directory))
