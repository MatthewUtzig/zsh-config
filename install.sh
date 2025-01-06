
echo "Installing for user $USER"
echo "source ~/.zshconfig/.zshrc" > ~/.zshrc

git clone https://github.com/MatthewUtzig/zsh-config $HOME/.zshconfig
ln -s $HOME/.zshconfig/.oh-my-zsh $HOME/.oh-my-zsh
mkdir -p $HOME/tmp

if grep -q '^ID=arch' /etc/os-release; then
    update-yay
fi

