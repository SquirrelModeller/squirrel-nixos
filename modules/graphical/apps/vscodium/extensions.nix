pkgs:
(with pkgs.vscode-extensions; [
  jnoortheen.nix-ide

  ms-python.python
  ms-python.black-formatter
  detachhead.basedpyright

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
  (pkgs.vscode-utils.buildVscodeExtension {
    pname = "claude-session-names";
    version = "0.1.0";
    src = ./claude-session-names;
    # src is a plain directory, not a .vsix
    sourceRoot = "ext";
    unpackPhase = "mkdir ext && cp -r --no-preserve=mode $src/. ext";
    vscodeExtPublisher = "squirrel";
    vscodeExtName = "claude-session-names";
    vscodeExtUniqueId = "squirrel.claude-session-names";
  })
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
  (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "nolanderc";
      name = "glsl-analyzer";
      version = "1.3.0";
      sha256 = "sha256-M4Lx+8LlcD0UpREjUc9z1VOOxgIOmstbvuWYNEwnlWo=";
    };
  })
  (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "slevesque";
      name = "shader";
      version = "1.1.5";
      sha256 = "sha256-Pf37FeQMNlv74f7LMz9+CKscF6UjTZ7ZpcaZFKtX2ZM=";
    };
  })
]
