# change default font size of GTK apps from 10 to 10.5
# gsettings set org.gnome.desktop.interface font-name 'sans 10.5'
# gsettings set org.gnome.desktop.interface document-font-name 'sans 10.5'
# gsettings set org.gnome.desktop.interface monospace-font-name 'monospace 10.5'
#
# and for xwayland apps:
# mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
# "[ -f ~/.config/gtk-3.0/settings.ini ] || \
# 	printf '[Settings]\ngtk-font-name = Sans 10.5\n' > ~/.config/gtk-3.0/settings.ini"
# "[ -f ~/.config/gtk-4.0/settings.ini ] || cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/"
