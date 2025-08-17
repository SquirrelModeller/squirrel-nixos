(deftheme my-kitty
  "A custom theme with an orange/red color scheme on a dark background.")

(let ((class '((class color) (min-colors 89)))
      (color0 "{{ color0 }}")
      (color1 "{{ color1 }}")
      (color2 "{{ color2 }}")
      (color3 "{{ color3 }}")
      (color4 "{{ color4 }}")
      (color5 "{{ color5 }}")
      (color6 "{{ color6 }}")
      (color7 "{{ color7 }}")
      (color8 "{{ color8 }}")
      (color9 "{{ color9 }}")
      (color10 "{{ color10 }}")
      (color11 "{{ color11 }}")
      (color12 "{{ color12 }}")
      (color13 "{{ color13 }}")
      (color14 "{{ color14 }}")
      (color15 "{{ color15 }}")
      (selection-foreground "#928374")
      (selection-background "{{ background }}")
      (background "#1f1f1f")
      (foreground "#FFFFFF")
      (cursor-color "#b29d89")
      (text-color "#1E1E1E"))

  (custom-theme-set-faces
   'my-kitty
   ;; Basics
   `(default ((,class (:background ,background :foreground ,color0))))
   `(cursor ((,class (:background ,cursor-color))))
   `(region ((,class (:background ,selection-background :foreground ,selection-foreground))))
   `(highlight ((,class (:background ,color15))))
   `(fringe ((,class (:background ,background :foreground ,color7))))
   `(line-number ((,class (:background ,background :foreground ,color7))))
   `(line-number-current-line ((,class (:background ,background :foreground ,color15))))

   `(mode-line ((,class (:background ,background :foreground ,selection-foreground))))
   `(mode-line-inactive ((,class (:background ,color4 :foreground ,selection-foreground))))

   ;; Font lock
   `(font-lock-builtin-face ((,class (:foreground ,color5))))
   `(font-lock-comment-face ((,class (:foreground ,color7))))
   `(font-lock-constant-face ((,class (:foreground ,color6))))
   `(font-lock-function-name-face ((,class (:foreground ,color2))))
   `(font-lock-keyword-face ((,class (:foreground ,color1))))
   `(font-lock-string-face ((,class (:foreground ,color12))))
   `(font-lock-type-face ((,class (:foreground ,color4))))
   `(font-lock-variable-name-face ((,class (:foreground ,color6))))
   `(font-lock-warning-face ((,class (:foreground ,color1 :weight bold))))

   `(minibuffer-prompt ((,class (:foreground ,color2 :weight bold))))

   ;; Extras
   `(powerline-active1 ((,class (:background ,color2 :foreground ,selection-foreground))))
   `(powerline-active2 ((,class (:background ,background :foreground ,selection-foreground))))
   `(powerline-inactive1 ((,class (:background ,color4 :foreground ,selection-foreground))))
   `(powerline-inactive2 ((,class (:background ,color5 :foreground ,selection-foreground))))

   `(elscreen-tab-background-face ((,class (:background ,background :foreground ,text-color))))
   `(elscreen-tab-control-face ((,class (:background ,color1 :foreground ,text-color))))
   `(elscreen-tab-current-screen-face ((,class (:background ,color2 :foreground ,text-color))))
   `(elscreen-tab-other-screen-face ((,class (:background ,color4 :foreground ,text-color))))))

(provide-theme 'my-kitty)
