#!/bin/bash
set -x

touch /tmp/init.log

exec > /tmp/init.log 2>&1

# c220g5 specific
disk_dev=/dev/sda4
work_dir=/pythia
repo=https://github.com/arhsis/pythia.git

function setup_workdir() {
    sudo mkdir -p $work_dir
    sudo /usr/local/etc/emulab/mkextrafs.pl $work_dir
}


function setup_champsim() {
    git clone $repo $work_dir
    cd $work_dir
    git checkout dev

    git clone https://github.com/mavam/libbf.git libbf
    cd libbf
    mkdir build && cd build
    cmake ../
    make clean && make -j
}

function download_traces() {
    mkdir -p $work_dir/traces
    wget -O $work_dir/traces/603.bwaves_s-1080B.champsimtrace.xz https://dpc3.compas.cs.stonybrook.edu/champsim-traces/speccpu/603.bwaves_s-1080B.champsimtrace.xz
}

function setup_git_info() {
    # directly write the following content into /root/.gitconfig
    sudo tee /root/.gitconfig > /dev/null << 'EOF'
[user]
        name = arhsis
        email = arhsis2024@gmail.com
[credential]
        helper = cache
EOF

}

function setup_utils() {
   sudo apt-get update
   sudo apt-get --yes install neovim tmux htop autojump ripgrep perl
   # conda env, autojump, set default editor to nvim
   sudo sh -c 'echo "export PATH=\"/tip/miniforge3/bin:\$PATH\"" >> /root/.bashrc && \
   echo ". /usr/share/autojump/autojump.sh" >> /root/.bashrc && \
   echo "export VISUAL=nvim" >> /root/.bashrc && \
   echo "export EDITOR=\"\$VISUAL\"" >> /root/.bashrc'
}

setup_workdir
setup_champsim
download_traces
setup_utils
setup_git_info
