{ lib, osConfig, ... }:
let
  inherit (lib) mkIf;
  inherit (osConfig) modules;
  inherit (modules.style.colorScheme) colors;
in
{
  xdg.configFile."emacs/themes/my-kitty-theme.el".text = ''
    (deftheme my-kitty
      "A custom theme with an orange/red color scheme on a dark background.")

    (let ((class '((class color) (min-colors 89)))
          (color0 "${colors.base00}")
          (color1 "${colors.base01}")
          (color9 "${colors.base09}")
          (color2 "${colors.base02}")
          (color10 "${colors.base0A}")
          (color3 "${colors.base03}")
          (color11 "${colors.base0B}")
          (color4 "${colors.base04}")
          (color12 "${colors.base0C}")
          (color5 "${colors.base05}")
          (color13 "${colors.base0D}")
          (color6 "${colors.base06}")
          (color14 "${colors.base0E}")
          (color7 "${colors.base07}")
          (color15 "${colors.base0F}")
          (selection-foreground "#928374")
          (selection-background "#30302f")
          (background "#1f1f1f")
          (foreground "#FFFFFF")
          (cursor-color "#b29d89")
          (text-color "#1E1E1E")
    )

    (custom-theme-set-faces
      'my-kitty
      ;; Basic theming
      `(default ((,class (:background ,background :foreground ,color0))))
      `(cursor ((,class (:background ,cursor-color))))
      `(region ((,class (:background ,selection-background :foreground ,selection-foreground))))
      `(highlight ((,class (:background ,color15))))
      `(fringe ((,class (:background ,background :foreground ,color7))))
      `(line-number ((,class (:background ,background :foreground ,color7))))
      `(line-number-current-line ((,class (:background ,background :foreground ,color15))))
  
      `(mode-line ((,class (:background ,background :foreground ,selection-foreground))))
      `(mode-line-inactive ((,class (:background ,color4 :foreground ,selection-foreground))))

      ;; Font lock (syntax highlighting)
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
  
      `(powerline-active1 ((,class (:background ,color2 :foreground ,selection-foreground))))
      `(powerline-active2 ((,class (:background ,background :foreground ,selection-foreground))))
      `(powerline-inactive1 ((,class (:background ,color4 :foreground ,selection-foreground))))
      `(powerline-inactive2 ((,class (:background ,color5 :foreground ,selection-foreground))))
  
      `(elscreen-tab-background-face ((,class (:background ,background :foreground ,text-color))))
      `(elscreen-tab-control-face ((,class (:background ,color1 :foreground ,text-color))))
      `(elscreen-tab-current-screen-face ((,class (:background ,color2 :foreground ,text-color))))
      `(elscreen-tab-other-screen-face ((,class (:background ,color4 :foreground ,text-color))))
     )
    )

    (provide-theme 'my-kitty)
  '';
}


