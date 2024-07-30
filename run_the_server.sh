#!/bin/bash

COMFYUI_RUNNER_PATH="/app/ComfyUI/main.py"

# Start ComfyUI using the defined paths
if ! python3 $COMFYUI_RUNNER_PATH --listen --preview-method auto; then
    echo "Error: Failed to start ComfyUI" >&2
fi
