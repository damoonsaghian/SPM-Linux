# https://chrony-project.org/documentation.html
# https://gitlab.com/chrony/chrony

# ntp sets system time based on UTC which suffers from leap seconds
# "chrony -Q" prints the offset; add it to leap seconds, and adjust the system time using "adjtimex" command
# for this to work properly, system timezone must be set from "right" timezones in tzdata
# https://www.ucolick.org/~sla/leapsecs/right+gps.html
# https://skarnet.org/software/skalibs/flags.html#clockistai

# add gpsd as a time reference

# when chrony can't adjust time, try to set it using the time reported by modemmanager
# https://www.freedesktop.org/software/ModemManager/api/latest/gdbus-org.freedesktop.ModemManager1.Modem.Time.html

# time sync over gnunet -> ip over gnunet
