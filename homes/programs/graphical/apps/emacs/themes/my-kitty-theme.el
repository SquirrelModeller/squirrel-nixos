(deftheme my-kitty
  "A custom theme with an orange/red color scheme on a dark background.")

(let ((class '((class color) (min-colors 89)))
      (color1 "#D35151")
      (color9 "#fb4934")
      (color2 "#FCCD94")
      (color10 "#D9843F")
      (color3 "#A87773C")
      (color11 "#fabd2d")
      (color4 "#E2D3AB")
      (color12 "#FFFFBB")
      (color5 "#b16286")
      (color13 "#d3869b")
      (color6 "#FFCF95")
      (color14 "#8ec07c")
      (color7 "#ada498")
      (color15 "#928374")
      (selection-foreground "#928374")
      (selection-background "#30302f")
      (background "#1e1e1e")  ;; Slightly brighter background
      (foreground "#FFFFFF")  ;; Light foreground for better readability
      (cursor-color "#FF9D64")  ;; Light orange cursor
      (text-color "#1E1E1E"))

  (custom-theme-set-faces
   'my-kitty

   ;; Basic theming
   `(default ((,class (:background ,background :foreground ,foreground))))
   `(cursor ((,class (:background ,cursor-color))))
   `(region ((,class (:background ,selection-background :foreground ,selection-foreground))))
   `(highlight ((,class (:background ,color4))))
   `(fringe ((,class (:background ,background :foreground ,color7))))
   `(line-number ((,class (:background ,background :foreground ,color7))))
   `(line-number-current-line ((,class (:background ,background :foreground ,color15))))

   ;; Mode line
   `(mode-line ((,class (:background ,color3 :foreground ,selection-foreground))))
   `(mode-line-inactive ((,class (:background ,color4 :foreground ,selection-foreground))))

   ;; Font lock (syntax highlighting)
   `(font-lock-builtin-face ((,class (:foreground ,color5))))
   `(font-lock-comment-face ((,class (:foreground ,color7))))
   `(font-lock-constant-face ((,class (:foreground ,color6))))
   `(font-lock-function-name-face ((,class (:foreground ,color2))))
   `(font-lock-keyword-face ((,class (:foreground ,color1))))
   `(font-lock-string-face ((,class (:foreground ,color3))))
   `(font-lock-type-face ((,class (:foreground ,color4))))
   `(font-lock-variable-name-face ((,class (:foreground ,color10))))
   `(font-lock-warning-face ((,class (:foreground ,color9 :weight bold))))

   ;; Minibuffer
   `(minibuffer-prompt ((,class (:foreground ,color2 :weight bold))))

   ;; Powerline
   `(powerline-active1 ((,class (:background ,color2 :foreground ,selection-foreground))))
   `(powerline-active2 ((,class (:background ,color3 :foreground ,selection-foreground))))
   `(powerline-inactive1 ((,class (:background ,color4 :foreground ,selection-foreground))))
   `(powerline-inactive2 ((,class (:background ,color5 :foreground ,selection-foreground))))

   ;; ElScreen
      `(elscreen-tab-background-face ((,class (:background ,background :foreground ,text-color)))) ;; Tab background
   `(elscreen-tab-control-face ((,class (:background ,color1 :foreground ,text-color)))) ;; Control tab
   `(elscreen-tab-current-screen-face ((,class (:background ,color2 :foreground ,text-color)))) ;; Current screen tab
   `(elscreen-tab-other-screen-face ((,class (:background ,color4 :foreground ,text-color)))) ;; Other screen tabs
 
   ))

(provide-theme 'my-kitty)
