# https://github.com/qt/qtmultimedia/tree/dev

# don't compile multimediawidget
# ffmpeg backend https://github.com/qt/qtmultimedia/blob/dev/src/plugins/multimedia/ffmpeg/CMakeLists.txt
# 	disable QT_FEATURE_xlib
# https://github.com/qt/qtmultimedia/blob/dev/src/multimedia/CMakeLists.txt
# enable alsa, disable pulse, disable network
