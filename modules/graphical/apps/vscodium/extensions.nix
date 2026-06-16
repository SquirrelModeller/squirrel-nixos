pkgs:
(with pkgs.vscode-extensions; [
  jnoortheen.nix-ide

  # ms-python.python
  # ms-python.black-formatter

  # ms-toolsai.jupyter
  # ms-toolsai.jupyter-keymap
  # ms-toolsai.jupyter-renderers

  mkhl.direnv
  eamodio.gitlens
  yzhang.markdown-all-in-one
  usernamehw.errorlens
  tomoki1207.pdf

  svelte.svelte-vscode
  esbenp.prettier-vscode
  dbaeumer.vscode-eslint

  rust-lang.rust-analyzer

  llvm-vs-code-extensions.vscode-clangd
  vadimcn.vscode-lldb

  anthropic.claude-code

  geequlim.godot-tools
])
++ [
  (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "TheQtCompany";
      name = "qt-core";
      version = "1.15.0";
      sha256 = "sha256-GVffx5YoLyemzLJ7jIEk0+0vwfP9mACwDJtenyhEN0Y=";
    };
  })
  (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "TheQtCompany";
      name = "qt-qml";
      version = "1.15.0";
      sha256 = "sha256-UiInoW6OYRpTeiMQlQ9IQChb7k2o4ploxeNRNgAv3do=";
    };
  })
]
