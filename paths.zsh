PATH="$PATH:/usr/bin/core_perl:/usr/bin/vendor_perl"
cabal_bin="$HOME/.cabal/bin"
if [ -d "$cabal_bin" ]; then
    PATH="$PATH:$cabal_bin"
fi
