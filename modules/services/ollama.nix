{...}: let
  dataDir = "/work/ollama";
in {
  systemd.tmpfiles.rules = ["d ${dataDir} 0750 ollama ollama -"];

  services.ollama = {
    enable = true;
    user = "ollama";
    group = "ollama";
    home = dataDir;
    host = "127.0.0.1";
    loadModels = ["hf.co/mradermacher/Qwen3-32B-heretic-i1-GGUF:Q4_K_M"];
    syncModels = true;

    environmentVariables = {
      HIP_VISIBLE_DEVICES = "0";
    };
  };
}
