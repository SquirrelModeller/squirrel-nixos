let
  daedalus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMzEdTGBn8WGhlQuIDXyJcmMv+9ZFICyxSbkVQ+asgb root@daedalus";
  talos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIINthjSz4/LhSOJWw69E0J9+xRM3uDHfqak/7TcvfZi6 root@talos";
in {
  "rrss-env.age".publicKeys = [talos daedalus];
}
