project_dir="$(dirname "$0")"

# https://gitlab.freedesktop.org/pipewire/pipewire
# https://wiki.alpinelinux.org/wiki/PipeWire
# https://docs.voidlinux.org/config/media/pipewire.html
# https://wiki.archlinux.org/title/PipeWire

# gst-plugin-pipewire
# pipewire-pulse
# pipewire-spa-bluez

mkdir -p etc/wireplumber/main.lua.d
echo 'device_defaults.properties = {
	["default-volume"] = 1.0,
	["default-input-volume"] = 1.0,
}' > etc/wireplumber/main.lua.d/51-default-volume.lua
