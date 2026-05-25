let
  daedalus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMzEdTGBn8WGhlQuIDXyJcmMv+9ZFICyxSbkVQ+asgb root@daedalus";
  talos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIINthjSz4/LhSOJWw69E0J9+xRM3uDHfqak/7TcvfZi6 root@talos";
  iris = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQcs9oY+tXYdT5HxqhEd4DMzdLX8sJOvXLyQr5XOXh4 root@iris";
in {
  "rrss-env.age".publicKeys = [talos daedalus];
  "forgejo-admin-password.age".publicKeys = [talos daedalus];
  "grafana-admin-password.age".publicKeys = [iris];
  "grafana-secret-key.age".publicKeys = [iris];
}
