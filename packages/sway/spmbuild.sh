apt-get -qq install sway swayidle xwayland lua5.3 lua-lgi gir1.2-gtk-4.0 gnome-console
cp /mnt/os/{sway.conf,swapps.py} /usr/local/share/

# bin/sway:
# #!sh
# $script_dir/sway -c $script_dir/sway.conf
#
# this is to prevent normal users from changing Sway's config
# this means that, swayidle can't be disabled by a normal user (see sway.conf)

# https://github.com/wmww/gtk4-layer-shell

# hardlink swaycap.py to swaycap and make it executable

# lock screen:
# a window in workspace "lockscreen" that asks for password
# when lock screen is activated, sway goes to "lock" mode with its own set of keybindings
# if an empty password is entered, or "escape" is pressed, show a readonly view of the projects
# 	note that external storage devices will be writable
# when one trys to edit readonly files, or when "alt+tab" is pressed, or when "escape" is pressed in the root window,
# 	show the password entry
# during boot, the user will be automatically logged in, and the lock screen will be activated
# when lock window is closed, reopen it

# after 600 seconds idle, lock
# idle can be monitored using a user service)
# dim screen in several steps before locking

# to prevent BadUSB, when a new input device is connected lock the session
# a user service checks when "/spm/installed/system/new-input-added" file is created, locks the session
# mdev rule that when an input device (ATTR{bInterfaceClass}=="03") is added:
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
