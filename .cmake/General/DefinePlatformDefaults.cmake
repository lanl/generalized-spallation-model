# ============================================================================ #
#
# Set system vars
#
# ============================================================================ #
cmake_minimum_required (VERSION 3.8.0)

if (CMAKE_SYSTEM_NAME MATCHES "Linux")
    set(LINUX TRUE)
endif(CMAKE_SYSTEM_NAME MATCHES "Linux")

if (CMAKE_SYSTEM_NAME MATCHES "Darwin")
	set (OSX TRUE)
endif (CMAKE_SYSTEM_NAME MATCHES "Darwin")

if (CMAKE_SYSTEM_NAME MATCHES "FreeBSD")
    set(FREEBSD TRUE)
    set(BSD TRUE)
endif (CMAKE_SYSTEM_NAME MATCHES "FreeBSD")

if (CMAKE_SYSTEM_NAME MATCHES "OpenBSD")
    set(OPENBSD TRUE)
    set(BSD TRUE)
endif (CMAKE_SYSTEM_NAME MATCHES "OpenBSD")

if (CMAKE_SYSTEM_NAME MATCHES "NetBSD")
    set(NETBSD TRUE)
    set(BSD TRUE)
endif (CMAKE_SYSTEM_NAME MATCHES "NetBSD")

if (CMAKE_SYSTEM_NAME MATCHES "(Solaris|SunOS)")
    set(SOLARIS TRUE)
endif (CMAKE_SYSTEM_NAME MATCHES "(Solaris|SunOS)")

if (CMAKE_SYSTEM_NAME MATCHES "OS2")
    set(OS2 TRUE)
endif (CMAKE_SYSTEM_NAME MATCHES "OS2")

