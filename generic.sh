#!/bin/bash

if [[ $(id -u) -eq 0 ]] ; then echo "Please run as non-root" ; exit 1 ; fi

# Kill the whole script on CTRL+C
trap "exit" INT

echo "Removing old configs"
rm -rf ~/.bashrc
rm -rf ~/.gitconfig
rm -rf ~/.config/nvim
rm -rf ~/.gnupg/gpg.conf ~/.gnupg/gpg-agent.conf
rm -rf ~/.vimrc
rm -rf ~/.vim
rm -rf ~/.config/yakuakerc
rm -rf ~/.config/konsolerc
rm -rf ~/.gitmessage
rm -rf ~/.local/share/konsole/czocher.profile

echo "Installing new config"
ln -s $PWD/.bashrc ~/.bashrc
mkdir -p ~/.gnupg
ln -s $PWD/.gnupg/gpg.conf ~/.gnupg/gpg.conf
ln -s $PWD/.gnupg/gpg-agent.conf ~/.gnupg/gpg-agent.conf
curl https://keybase.io/czocher/pgp_keys.asc | gpg --import

ln -s $PWD/.gitconfig ~/.gitconfig
ln -s $PWD/.gitmessage ~/.gitmessage
ln -s $PWD/nvim ~/.config/nvim
ln -s $PWD/nvim ~/.vim
ln -s $PWD/nvim/init.vim ~/.vimrc
ln -s $PWD/other/yakuakerc ~/.config/yakuakerc
ln -s $PWD/other/konsolerc ~/.config/konsolerc
ln -s $PWD/other/czocher.profile ~/.local/share/konsole/czocher.profile
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "Downloading powerline fonts"
git clone https://github.com/powerline/fonts.git && cd fonts && ./install.sh && cd .. && rm -rf fonts/
echo "Configure the terminal to use powerline fonts"

echo "Downloading FiraCode"
mkdir -p ~/.local/share/fonts
for type in Bold Light Medium Regular Retina; do
  wget -O ~/.local/share/fonts/FiraCode-${type}.ttf "https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-${type}.ttf?raw=true";
done
fc-cache -f

echo "Downloading git-aware-prompt"
git clone git://github.com/jimeh/git-aware-prompt.git .bash/git-aware-prompt
ln -s $PWD/.bash ~/.bash

echo "Downlading rust"
curl https://sh.rustup.rs -sSf | bash -s -- -y
rustup self update
rustup install nightly
rustup component add rls-preview --toolchain nightly
rustup component add rust-analysis --toolchain nightly
rustup component add rust-src --toolchain nightly

echo "Configuring gpg"
# Set ownership to your own user and primary group
chown -R "$USER:$(id -gn)" ~/.gnupg
# Set permissions to read, write, execute for only yourself, no others
chmod 700 ~/.gnupg
# Set permissions to read, write for only yourself, no others
chmod 600 ~/.gnupg/*

echo "Configuring git"
echo "Provide the user email for git: "
read email
git config --global user.email "$email"

echo "Downloading oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
rm -rf ~/.zshrc
ln -s $PWD/.zshrc ~/.zshrc

echo "Update nvim plugins"
nvim +PlugInstall +UpdateRemotePlugins +qa

echo "Finished"
