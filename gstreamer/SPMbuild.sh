project_dir="$(dirname "$0")"

# https://gitlab.freedesktop.org/gstreamer/gstreamer
# gst-plugins-base: don't provide xlib
# gst-plugins-good: don't provide xlib gtk3 libsoup3
# gst-plugins-ugly: don't provide sidplay
# gst-plugins-bad: av1(aom-libs), h264(openh264), h265(libde265), aac(faad2)
# 	don't provide xlib gtk3 directfb dc1394 libopenni curl openssl libneon microdns
# 	bluez libfreeaptx liblc3 libsbc libldacbt flite
# 	fdk-aac vo-aacenc vo-amrwbenc sndfile soundtouch spandsp libwildmidi2 libzxing2
# https://github.com/Rafostar/clapper/tree/master/src/lib/gst/plugin
