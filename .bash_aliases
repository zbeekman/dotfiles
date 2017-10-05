alias stampede="ssh -tt login.xsede.org gsissh -p 2222 -tt stampede.tacc.xsede.org"
eval "$(hub alias -s)"
alias qemacs="emacs -nw -Q"
alias temacs="emacs -nw"
alias s="cd ~/Sandbox"
function fortags {
       find ${@-.} -name '*.[fF]90' ! -name '*__genmod.*' | xargs fortran-tags.py -g
       }
