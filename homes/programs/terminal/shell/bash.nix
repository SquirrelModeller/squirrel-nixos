{
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      export SSH_AUTH_SOCK="/run/user/1000/ssh-agent"
      eval "$(direnv hook bash)" 
    '';
  };
}
