(defconst sq/store-init-dir user-emacs-directory)

;; Because emacs is written to store, I need to redirect all temp files to writable places
;; This seems to work. I think I got everything, I hope.

;; XDG helpers
(defun sq/xdg (env fallback)
  (expand-file-name (or (getenv env) fallback) "~"))

(defconst sq/xdg-cache (file-name-as-directory (sq/xdg "XDG_CACHE_HOME" ".cache")))
(defconst sq/xdg-config (file-name-as-directory (sq/xdg "XDG_CONFIG_HOME" ".config")))
(defconst sq/xdg-state (file-name-as-directory (sq/xdg "XDG_STATE_HOME" ".local/state")))
(defconst sq/xdg-data  (file-name-as-directory (sq/xdg "XDG_DATA_HOME" ".local/share")))

;; Runtime dir writable, separate from the store
(setq user-emacs-directory (expand-file-name "emacs/" sq/xdg-config))
(dolist (d (list
            user-emacs-directory
            (expand-file-name "themes" user-emacs-directory)
            (expand-file-name "emacs/" sq/xdg-cache)
            (expand-file-name "emacs/" sq/xdg-state)
            (expand-file-name "emacs/" sq/xdg-data)))
  (make-directory d t))

;; All files Emacs writes -> XDG
(setq custom-file                        (expand-file-name "custom.el" user-emacs-directory))
(setq recentf-save-file                  (expand-file-name "emacs/recentf" sq/xdg-state))
(setq savehist-file                      (expand-file-name "emacs/savehist" sq/xdg-state))
(setq bookmark-default-file              (expand-file-name "emacs/bookmarks" sq/xdg-data))
(setq url-history-file                   (expand-file-name "emacs/url/history" sq/xdg-data))
(setq tramp-persistency-file-name        (expand-file-name "emacs/tramp" sq/xdg-cache))
(setq project-list-file                  (expand-file-name "emacs/projects" sq/xdg-data))
(setq package-user-dir                   (expand-file-name "emacs/elpa" sq/xdg-data))
(let ((eln (expand-file-name (format "emacs/eln-%s" emacs-version) sq/xdg-cache)))
  (make-directory eln t)
  (when (boundp 'native-comp-eln-load-path)
    (setq native-comp-eln-load-path (list eln))))

;; Autosaves / backups -> /tmp
(setq auto-save-file-name-transforms `((".*" ,(concat temporary-file-directory "\\1") t)))
(setq make-backup-files nil)
(setq backup-directory-alist `((".*" . ,temporary-file-directory)))
(setq create-lockfiles nil)

;; Themes & config from immutable store:
(add-to-list 'custom-theme-load-path (file-name-concat sq/store-init-dir "themes"))
(when (file-exists-p custom-file) (load custom-file nil t))
(setq package-enable-at-startup nil)

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(setq frame-inhibit-implied-resize t
      inhibit-splash-screen t
      use-dialog-box nil
      gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(load-file (expand-file-name "config.el" sq/store-init-dir))
