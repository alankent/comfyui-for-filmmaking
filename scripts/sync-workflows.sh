#!/usr/bin/env bash
set -euo pipefail

# Must set this before running:
# export COMFYUI_WORKFLOWS="/d/ComfyUI-python/ComfyUI/user/default/workflows"

if [ -z "${COMFYUI_WORKFLOWS-}" ]; then
  #echo "Please set COMFYUI_WORKFLOWS to your ComfyUI workflows folder"
  #exit 1
  export COMFYUI_WORKFLOWS=/d/comfyui-python/ComfyUI/user/default/workflows
fi

# Root of Git repo workflows directory
REPO_ROOT="$(pwd)/workflows"

# Check if workflows folder exists
if [ ! -d "$REPO_ROOT" ]; then
  echo "Error: 'workflows' directory not found in current directory."
  echo "Please run this script from the root of your Git repo."
  exit 1
fi

# Find all JSON files in the repo workflows tree
find "$REPO_ROOT" -type f -name "*.json" | while read -r repo_file; do
  # Determine relative path from workflows root
  rel_path="workflows/${repo_file#$REPO_ROOT/}"
  
  # Get just the basename (ignore subdirectory structure)
  base_name="$(basename "$repo_file")"

  # Corresponding ComfyUI file
  source_file="$COMFYUI_WORKFLOWS/$base_name"

  #ls -l $source_file
  #ls -l $repo_file

  if [ -f "$source_file" ]; then
    # Compare modification times
    if [ ! -s "$repo_file" ] || [ "$source_file" -nt "$repo_file" ]; then
      #echo "Updating $repo_file from ComfyUI source"
      echo "Updating $rel_path from ComfyUI source"
      # Make sure destination directory exists
      mkdir -p "$(dirname "$repo_file")"
      # Prettify
      jq --indent 2 . < "$source_file" > "$repo_file"
    else
      #echo "Skipping $repo_file"
      echo "Skipping $rel_path"
    fi
  else
    echo "$source_file does not exist"
  fi
done

echo "Done syncing workflows"
