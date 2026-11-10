{pkgs, ...}: let
  dataDir = "/work/comfyui";
  hf = "https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main";

  hfQwen = "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files";
  hfEdit = "https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files";
  hfHeretic = "https://huggingface.co/pottokao/Qwen-Image-2.1-Text-Encoder-Heretic-GGUF/resolve/main";
  hfLightning = "https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main";
  hfMiniMax = "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main";
  hfLtx = "https://huggingface.co/Lightricks/LTX-2.5/resolve/main";
  hfGemma = "https://huggingface.co/Comfy-Org/gemma-4/resolve/main";

  fetchModels = pkgs.writeShellApplication {
    name = "comfyui-fetch-models";
    runtimeInputs = [pkgs.curl];
    text = ''
      auth=()
      if [ -n "''${HF_TOKEN:-}" ]; then
        auth=(-H "Authorization: Bearer $HF_TOKEN")
      fi
      fetch() {
        mkdir -p "${dataDir}/models/$1"
        curl -fL -C - "''${auth[@]}" -o "${dataDir}/models/$1/$2" "''${3:-${hf}/$1/$2}"
      }
      # int8 convrot kernels produce garbage on ROCm (gfx1100), so use bf16
      fetch diffusion_models qwen_image_2.1_bf16.safetensors
      fetch text_encoders qwen3vl_8b_bf16.safetensors
      # prompt enhancer (the template requires the file even when refine_prompt is off)
      fetch text_encoders qwen3.5_9b_qwen_image_2.1_pe_t2i.int8_convrot.safetensors
      # same for the Image Edit template
      fetch text_encoders qwen3.5_9b_qwen_image_2.1_pe_i2i.int8_convrot.safetensors
      fetch vae qwen_image_2.1_vae_bf16.safetensors
      # community text encoder with refusals ablated, drop-in for qwen3vl_8b_bf16
      fetch text_encoders qwen3vl_8b_bf16_heretic.safetensors "${hfHeretic}/qwen3vl_8b_bf16_heretic.safetensors"

      # Qwen-Image-Edit-2509 template (older model, fp8 + 4-step Lightning LoRA)
      fetch diffusion_models qwen_image_edit_2509_fp8_e4m3fn.safetensors "${hfEdit}/diffusion_models/qwen_image_edit_2509_fp8_e4m3fn.safetensors"
      fetch loras Qwen-Image-Edit-2509-Lightning-4steps-V1.0-bf16.safetensors "${hfLightning}/Qwen-Image-Edit-2509/Qwen-Image-Edit-2509-Lightning-4steps-V1.0-bf16.safetensors"
      fetch text_encoders qwen_2.5_vl_7b_fp8_scaled.safetensors "${hfQwen}/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors"
      fetch vae qwen_image_vae.safetensors "${hfQwen}/vae/qwen_image_vae.safetensors"

      # MiniMax H3 video templates (~39 GB total)
      fetch loras minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors "${hfMiniMax}/loras/minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors"
      fetch vae minimax_h3_audio_vae_fp32.safetensors "${hfMiniMax}/vae/minimax_h3_audio_vae_fp32.safetensors"
      fetch vae minimax_h3_video_vae_int8_convrot.safetensors "${hfMiniMax}/vae/minimax_h3_video_vae_int8_convrot.safetensors"
      fetch text_encoders qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors "${hfMiniMax}/text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors"
      fetch diffusion_models minimax_h3_fl2va_pruned_int8_convrot.safetensors "${hfMiniMax}/diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors"

      # LTX-2.5 video/audio templates (gated)
      fetch vae ltx-2.5-audio-vae-bf16.safetensors "${hfLtx}/vae/ltx-2.5-audio-vae-bf16.safetensors"
      fetch vae ltx-2.5-video-vae-bf16.safetensors "${hfLtx}/vae/ltx-2.5-video-vae-bf16.safetensors"
      fetch text_encoders gemma4_e2b_it_int8_convrot.safetensors "${hfGemma}/text_encoders/gemma4_e2b_it_int8_convrot.safetensors"
      fetch text_encoders gemma4-12b-with-proj-ltx-2.5-comfy-int8-convrot.safetensors "${hfLtx}/text_encoders/gemma4-12b-with-proj-ltx-2.5-comfy-int8-convrot.safetensors"
      fetch diffusion_models ltx-2.5-22b-distilled-transformer-comfy-int8-convrot.safetensors "${hfLtx}/diffusion_models/ltx-2.5-22b-distilled-transformer-comfy-int8-convrot.safetensors"
      fetch latent_upscale_models ltx-2.5-latent-spatial-upscaler-x2-bf16-1.0.safetensors "${hfLtx}/latent_upscale_models/ltx-2.5-latent-spatial-upscaler-x2-bf16-1.0.safetensors"
    '';
  };
in {
  users.users.comfyui = {
    isSystemUser = true;
    group = "comfyui";
    home = dataDir;
    extraGroups = ["video" "render"];
  };
  users.groups.comfyui = {};

  systemd.tmpfiles.rules = ["d ${dataDir} 2775 squirrel comfyui -"];

  environment.systemPackages = [fetchModels];

  # Shits not gonna be active all the time
  systemd.services.comfyui = {
    description = "ComfyUI";
    after = ["network.target"];
    environment = {
      # 7900 XTX is gfx1100, which ROCm supports natively
      HIP_VISIBLE_DEVICES = "0";
      # rocprofiler-sdk exhausts KFD events, leaving ROCr's AsyncEventsLoop busy-spinning a core at idle
      HSA_TOOLS_DISABLE_REGISTER = "1";
    };
    serviceConfig = {
      User = "comfyui";
      Group = "comfyui";
      UMask = "0002";
      WorkingDirectory = dataDir;
      ExecStart = "${pkgs.comfyui}/bin/comfyui --listen 127.0.0.1 --port 8188 --base-directory ${dataDir} --disable-dynamic-vram --reserve-vram 4 --use-quad-cross-attention --disable-pinned-memory --disable-async-offload";
      Restart = "on-failure";
    };
  };
}
