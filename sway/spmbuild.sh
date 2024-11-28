project_dir="$(dirname "$0")"

apt-get -qq install sway swayidle xwayland lua5.3 lua-lgi gir1.2-gtk-4.0 gnome-console
cp /mnt/os/{sway.conf,swapps.py} /usr/local/share/

# bin/sway:
# #!sh
# $script_dir/sway -c $script_dir/sway.conf

# export as a graphical shell
echo '#!/exp/cmd/env sh
dbus-run-session sway
' > exp/cmd/gsh

# after 600 seconds idle: swapps lock, turn screen off
# idle can be monitored using a user service
# dim screen in several steps before turning screen off

# to prevent BadUSB, when a new input device is connected: swapps lock
# a user service checks when "/spm/installed/system/new-input-added" file is created, locks the session
# udev rule that when an input device (ATTR{bInterfaceClass}=="03") is added:
# 	 touch /spm/installed/system/new-input-added

# mono'space fonts:
# , wide characters are forced to squeeze
# , narrow characters are forced to stretch
# , bold characters don’t have enough room
# proportional font for code:
# , generous spacing
# , large punctuation
# , and easily distinguishable characters
# , while allowing each character to take up the space that it needs
# "https://github.com/iaolo/iA-Fonts/tree/master/iA%20Writer%20Quattro"
# "https://input.djr.com/"
apt-get -qq install fonts-noto-core fonts-hack
mkdir -p /etc/fonts
echo -n '<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
	<selectfont>
		<rejectfont>
			<pattern><patelt name="family"><string>NotoNastaliqUrdu</string></patelt></pattern>
			<pattern><patelt name="family"><string>NotoKufiArabic</string></patelt></pattern>
			<pattern><patelt name="family"><string>NotoNaskhArabic</string></patelt></pattern>
		</rejectfont>
	</selectfont>
	<alias>
		<family>serif</family>
		<prefer><family>NotoSerif</family></prefer>
	</alias>
	<alias>
		<family>sans</family>
		<prefer><family>NotoSans</family></prefer>
	</alias>
	<alias>
		<family>monospace</family>
		<prefer><family>Hack</family></prefer>
	</alias>
</fontconfig>
' > /etc/fonts/local.conf

# on'screen keyboard
# https://github.com/jjsullivan5196/wvkbd

# voice control:
# https://kalliope-project.github.io/
# https://gitlab.com/jezra/blather

# speech to text:
# https://github.com/openai/whisper
# https://github.com/julius-speech/julius
# https://github.com/alphacep/vosk-api
# https://github.com/kaldi-asr/kaldi
