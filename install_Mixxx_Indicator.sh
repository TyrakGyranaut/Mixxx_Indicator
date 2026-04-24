#!/bin/bash

# Mixxx_Indicator Installer
# Created by the Linux Queen :)

echo "--- Mixxx_Indicator Installation Assistant ---"

# 1. Install dependencies
echo "[1/4] Checking and installing dependencies..."
sudo apt update && sudo apt install -y python3-tk iproute2 pgrep

# 2. Create the application folder
echo "[2/4] Creating application directory..."
mkdir -p ~/Mixxx_Indicator

# 3. Create the Python script
echo "[3/4] Generating the indicator code..."
cat <<EOF > ~/Mixxx_Indicator/mixxx_indicator.py
import tkinter as tk
import subprocess
import os

def is_mixxx_running():
    try:
        # Check if the process 'mixxx' exists
        subprocess.check_output(["pgrep", "-x", "mixxx"])
        return True
    except:
        return False

def check_mixxx_stream():
    try:
        # Check if Mixxx has any active (ESTABLISHED) network connection
        result = subprocess.run("ss -tpn | grep -i 'mixxx' | grep -i 'ESTAB'", shell=True, capture_output=True)
        return True if result.returncode == 0 else False
    except:
        return False

class MixxxIndicator:
    def __init__(self, root):
        self.root = root
        self.root.title("Mixxx Indicator")
        self.size = 85
        # Set window size and floating position
        self.root.geometry(f"{self.size}x{self.size}+150+150")
        self.root.attributes("-topmost", True)
        
        self.canvas = tk.Canvas(root, width=self.size, height=self.size, bg='black', highlightthickness=0)
        self.canvas.pack(expand=True, fill="both")
        
        # Draw the status circle
        self.circle = self.canvas.create_oval(10, 10, self.size-10, self.size-10, fill="red", outline="white", width=3)
        
        # Start Mixxx if it is not already running
        if not is_mixxx_running():
            subprocess.Popen(["mixxx"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        self.update_loop()

    def update_loop(self):
        # Self-destruct if Mixxx is closed
        if not is_mixxx_running():
            self.root.destroy()
            return
            
        # Update color based on stream status
        if check_mixxx_stream():
            color = "#00FF00" # Green
            bg_color = "#002200" # Dark Green
        else:
            color = "#FF0000" # Red
            bg_color = "#220000" # Dark Red
            
        self.canvas.itemconfig(self.circle, fill=color)
        self.canvas.config(bg=bg_color)
        self.root.configure(bg=bg_color)
        
        self.root.after(3000, self.update_loop)

if __name__ == "__main__":
    root = tk.Tk()
    app = MixxxIndicator(root)
    root.mainloop()
EOF

# 4. Create the Desktop Starter
echo "[4/4] Creating Desktop shortcut..."
cat <<EOF > ~/Desktop/Mixxx_Indicator.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Mixxx Indicator
Comment=Start Mixxx with On-Air status light
Exec=python3 $HOME/Mixxx_Indicator/mixxx_indicator.py
Icon=media-record
Terminal=false
Categories=AudioVideo;Audio;
EOF

# Make the desktop file executable
chmod +x ~/Desktop/Mixxx_Indicator.desktop

echo ""
echo "--- INSTALLATION COMPLETE ---"
echo "You can now find the 'Mixxx Indicator' on your desktop."
echo "Happy Streaming!"

