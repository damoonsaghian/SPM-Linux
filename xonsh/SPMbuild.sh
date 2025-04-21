project_dir="$(dirname "$0")"

# https://savannah.gnu.org/git/?group=bash

cat <<-'EOF' > $build_dir/cmd/bash
#!/usr/bin/env sh
PS1="\e[7m \u@\h \e[0m \e[7m \w \e[0m\n> " bash
EOF
