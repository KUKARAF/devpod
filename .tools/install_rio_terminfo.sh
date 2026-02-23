curl -o rio.terminfo https://raw.githubusercontent.com/raphamorim/rio/main/misc/rio.terminfo
tic -xe xterm-rio,rio -o ~/.terminfo rio.terminfo
rm rio.terminfo

