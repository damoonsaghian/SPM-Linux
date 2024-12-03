project_dir="$(dirname "$0")"

# modemmanager A-GPS
# assisted data can be downloaded from SUPL servers: supl.google.com with 7276 or 7275 port
# then injected into the GPS device
# https://www.freedesktop.org/software/ModemManager/api/latest/gdbus-org.freedesktop.ModemManager1.Modem.Location.html#gdbus-method-org-freedesktop-ModemManager1-Modem-Location.InjectAssistanceData

# use gpsd for standalone gps devices (without cellular)
# https://gpsd.gitlab.io/gpsd/index.html
# gspd does not support injecting assisted data, yet
# actually i don't know if there is any standalone gps device with this ability

# https://wiki.archlinux.org/title/GPS
