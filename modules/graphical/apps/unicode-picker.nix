{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "unicode-picker";
      runtimeInputs = [ pkgs.python3 pkgs.curl pkgs.tofi pkgs.wl-clipboard ];
      text = ''
        DB="$HOME/.local/share/unicode-data.tsv"
        mkdir -p "$(dirname "$DB")"

        if [ ! -f "$DB" ] || [ "$(find "$DB" -mtime +30 2>/dev/null)" ]; then
          curl -fsSL https://unicode.org/Public/UCD/latest/ucd/UnicodeData.txt \
          | python3 -c '
        import sys
        for line in sys.stdin:
            fields = line.rstrip("\n").split(";")
            if len(fields) < 2:
                continue
            code_hex, name = fields[0], fields[1]
            if name.startswith("<") and name.endswith(">"):
                continue
            ch = chr(int(code_hex, 16))
            print(f"{ch}\tU+{code_hex}\t{name}")' \
                  > "$DB.tmp" && mv "$DB.tmp" "$DB"
                fi
        
            choice="$(tofi --prompt-text "Unicode" < "$DB")" || exit 0
            char="''${choice%%$'\t'*}"
            printf "%s" "$char" | wl-copy
      '';
    })
  ];
}
