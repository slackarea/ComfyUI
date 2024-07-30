FROM nvidia/cuda:12.5.1-runtime-ubuntu22.04

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
RUN apt install -y nano mc python3 python3-pip git wget
RUN pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121

# needed for libGL.so.1
RUN apt install -y ffmpeg libsm6 libxext6

RUN mkdir -p /app
WORKDIR /app

RUN git clone https://github.com/comfyanonymous/ComfyUI.git
WORKDIR /app/ComfyUI
RUN pip install -r requirements.txt

########################################################################################

# The following is the optional installation of additional plugins and workflows. Comment the ones you don't need.

RUN pip install gitpython

# Install ComfyUI Manager
RUN python3 -c "import git; git.Repo.clone_from('https://github.com/ltdrdata/ComfyUI-Manager', './custom_nodes/ComfyUI-Manager')"
RUN pip install -r custom_nodes/ComfyUI-Manager/requirements.txt

# Install Efficiency Nodes
RUN pip install simpleeval
RUN python3 -c "import git; git.Repo.clone_from('https://github.com/jags111/efficiency-nodes-comfyui', './custom_nodes/efficiency-nodes-comfyui')"

# Install pythongosssss custom scripts
RUN python3 -c "import git; git.Repo.clone_from('https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git', './custom_nodes/ComfyUI-Custom-Scripts')"

# Aspect ratio node can be found in image->SDXL Aspect Ratio
RUN wget -P custom_nodes https://raw.githubusercontent.com/throttlekitty/SDXLCustomAspectRatio/main/SDXLAspectRatio.py

# SDXl Prompt Styler, for easier access to prompts that create certain styles
RUN python3 -c "import git; git.Repo.clone_from('https://github.com/twri/sdxl_prompt_styler.git', './custom_nodes/sdxl_prompt_styler')"

# TAESD models, used for high-quality previews in nodes
RUN wget -P models/vae_approx https://github.com/madebyollin/taesd/raw/main/taesdxl_decoder.pth
RUN wget -P models/vae_approx https://github.com/madebyollin/taesd/raw/main/taesdxl_encoder.pth
RUN wget -P models/vae_approx https://github.com/madebyollin/taesd/raw/main/taesd_decoder.pth
RUN wget -P models/vae_approx https://github.com/madebyollin/taesd/raw/main/taesd_encoder.pth

# Alternative default workflow
COPY defaultGraph.js ./web/scripts
COPY extra_model_paths.yaml .

# These are needed by Krita plugin
RUN python3 -c "import git; git.Repo.clone_from('https://github.com/Acly/comfyui-tooling-nodes.git', './custom_nodes/comfyui-tooling-nodes')"
RUN python3 -c "import git; git.Repo.clone_from('https://github.com/cubiq/ComfyUI_IPAdapter_plus.git', './custom_nodes/ComfyUI_IPAdapter_plus')"
RUN python3 -c "import git; git.Repo.clone_from('https://github.com/Fannovel16/comfyui_controlnet_aux', './custom_nodes/comfyui_controlnet_aux')"
RUN sed -i '/trimesh/c\trimesh' custom_nodes/comfyui_controlnet_aux/requirements.txt # for some reason `trimesh[easy]` won't install, but `trimesh` will.
RUN pip install -r custom_nodes/comfyui_controlnet_aux/requirements.txt
RUN git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale --recursive ./custom_nodes/ComfyUI_UltimateSDUpscale

# ComfyUI-Impact-Pack - contains SAM (Segment Anything) and face fixing tools
RUN python3 -c "import git; git.Repo.clone_from('https://github.com/ltdrdata/ComfyUI-Impact-Pack.git', './custom_nodes/ComfyUI-Impact-Pack')"

# Run ComfyUI for the first time to make it install the dependencies it needs.
COPY run_the_server.sh /

RUN apt-get clean -y
RUN mkdir /comfyui

RUN chmod a+x /run_the_server.sh
EXPOSE 8188

CMD ["/run_the_server.sh"]

