#Configure path to include /usr/local/bin (required for ratom)
#Some instances of CentOS don't have this predefined
#Code from: http://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

pathadd /usr/local/bin
