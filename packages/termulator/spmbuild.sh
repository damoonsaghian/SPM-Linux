# https://gitlab.gnome.org/GNOME/vte

# scroll up: Page_Up
# scroll down: Page_Down
# copy: Control+c
# paste: Control+v
# new tab: Control+t
# next tab: Control+Page_Down
# previous tab: Control+Page_Up
# make "Escape" to act like ctrl+c (ie "\x03" character)

#background=000000
#foreground=FFFFFF
#regular0=403E41
#regular1=FF6188
#regular2=A9DC76
#regular3=FFD866
#regular4=FC9867
#regular5=AB9DF2
#regular6=78DCE8
#regular7=FCFCFA
#bright0=727072
#bright1=FF6188
#bright2=A9DC76
#bright3=FFD866
#bright4=FC9867
#bright5=AB9DF2
#bright6=78DCE8
#bright7=FCFCFA
#selection-background=555555
#selection-foreground=dddddd

mkdir -p "$project_dir"/.cache/spm

echo -n '[Desktop Entry]
Type=Application
Name=Terminal
Icon=terminal
Exec=termulator
StartupNotify=true
' > "$project_dir"/.cache/spm/terminal.desktop

mkdir -p /usr/local/share/icons/hicolor/scalable/apps
echo -n '<?xml version="1.0" encoding="UTF-8"?>
<svg height="128px" viewBox="0 0 128 128" width="128px">
	<path d="m 20 12 h 88 c 4.4 0 8 3.6 8 8 v 80 c 0 4.4 -3.6 8 -8 8 h -88 c -4.4 0 -8 -3.6 -8 -8 v -80 c 0 -4.4 3.6 -8 8 -8 z m 0 0" fill="#666666"/>
	<path d="m 20 14 h 88 c 3.3 0 6 2.7 6 6 v 80 c 0 3.3 -2.7 6 -6 6 h -88 c -3.3 0 -6 -2.7 -6 -6 v -80 c 0 -3.3 2.7 -6 6 -6 z m 0 0" fill="#222222"/>
	<g fill="#dddddd">
		<path d="m 46 40.9 l -14 -7.6 v 4.7 l 9.7 4.6 v 0.1 l -9.7 5.2 v 4.7 l 14 -8.2 z m 0 0"/>
		<path d="m 50 56 v 4 h 16 v -4 z m 0 0"/>
	</g>
</svg>
' > "$project_dir"/.cache/spm/icons/hicolor/scalable/apps/terminal.svg
