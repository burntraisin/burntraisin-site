+++
title = "MATLAB on EndeavourOS"
date = "2026-05-20"
tags = [ "guide" ]
+++

Early this spring semester, I had to install MATLAB for one of my classes. I wrote these steps up as I was trying to find a way to install the program back in Janurary. I recall heavily referencing [this Reddit comment](https://www.reddit.com/r/archlinux/comments/1n4ot2k/comment/npoh9kw/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button), which has since then been removed. Bummer. (˃̣̣̥ ︿ ˂̣̣̥)

If anyone out there is trying to install R2025b MATLAB on EndeavourOS/Arch, hopefully you find this helpful!

1. Install Docker, Distrobox, and mpm
    ```bash
    yay -S docker distrobox matlab-mpm
    ```

2. Activate Docker and add to user group
    ```bash
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
    newgrp docker
    ```

3. Install MATLAB through mpm
    ```bash
    mpm install --release=R2025b --destination=$HOME/.local/MATLAB/R2025b --products MATLAB
    ```

4. Create the container
    ```bash
    distrobox create -n matlab --image docker.io/debian:13 # Or you can use 12
    ```

5. Access the container
    ```bash
    distrobox enter matlab
    ```

6. Install dependencies within container
    ```bash
    sudo apt-get update && sudo apt-get install -y build-essential git procps locales
    sudo apt-get install task-desktop
    ```

7. Activate your license
    ```bash
    ~/.local/MATLAB/R2025b/bin/glnxa64/MathWorksProductAuthorizer
    ```

8. Execute MATLAB
    ```bash
    ~/.local/MATLAB/R2025b/bin/matlab -desktop
    ```

9. Create a `.desktop` file in `~./local/share/applications/`. It may look something like the following...
    ```text
    [Desktop Entry]
    Name=Matlab
    GenericName=Scientific Computing
    Comment=MATLAB on Debian
    Categories=Science;Development;Education
    Exec=/usr/bin/distrobox enter  matlab -- /home/<user>/.local/MATLAB/R2025b/bin/matlab -desktop
    Keywords=distrobox;
    Terminal=false
    TryExec=/usr/bin/distrobox
    Type=Application
    Actions=Remove;

    [Desktop Action Remove]
    Name=Remove Matlab from system
    Exec=/usr/bin/distrobox rm  matlab
    ```