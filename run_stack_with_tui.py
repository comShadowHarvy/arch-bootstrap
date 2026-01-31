#!/usr/bin/env python3
import yaml
import subprocess
import sys
import os

def main():
    compose_file = 'compose.yaml'
    tui_compose_file = 'compose.tui.yaml'

    if not os.path.exists(compose_file):
        print(f"Error: {compose_file} not found.")
        sys.exit(1)

    print(f"Reading {compose_file}...")
    with open(compose_file, 'r') as f:
        data = yaml.safe_load(f)

    # Modify to expose Ollama for TUI, keeping GPU support
    if 'services' in data:
        # 1. Modify Ollama service
        if 'ollama' in data['services']:
            ollama = data['services']['ollama']
            
            # NOTE: We are NOT removing the 'deploy' section here effectively preserving GPU support.
            
            # Expose port (Host:Container)
            # Use 11434 for host to match default
            print("Exposing Ollama on host port 11434...")
            if 'ports' not in ollama:
                ollama['ports'] = []
            ollama['ports'].append("11434:11434")
            
    # Write the new compose file
    print(f"Writing TUI-compatible configuration to {tui_compose_file}...")
    with open(tui_compose_file, 'w') as f:
        yaml.dump(data, f, sort_keys=False)

    # Run docker compose
    print("\nStopping running containers to ensure clean state...")
    stop_cmd = [
        "docker", "compose",
        "-f", tui_compose_file,
        "down"
    ]
    try:
        subprocess.run(stop_cmd, check=True)
    except subprocess.CalledProcessError:
        print("Warning: Failed to stop containers, or none were running. Proceeding...")

    print("\nStarting the stack in detached mode...")
    cmd = [
        "docker", "compose", 
        "-f", tui_compose_file, 
        "up", "-d", "--remove-orphans"
    ]
    
    try:
        subprocess.run(cmd, check=True)
        print("\nStack started successfully!")
        print("-" * 40)
        print("Paperless-ngx:  http://localhost:8000")
        print("Open WebUI:     http://localhost:3001")
        print("Ollama API:     http://localhost:11434")
        print("-" * 40)
        print(f"Note: You are running using the temporary file '{tui_compose_file}'.")
    except subprocess.CalledProcessError as e:
        print(f"\nError starting stack: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
