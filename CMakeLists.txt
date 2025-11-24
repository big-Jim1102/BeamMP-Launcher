cmake_minimum_required(VERSION 3.10)

project(Launcher)

if (WIN32)
    message(STATUS "MSVC -> forcing use of statically-linked runtime.")
    STRING(REPLACE "/MD" "/MT" CMAKE_CXX_FLAGS_RELEASE ${CMAKE_CXX_FLAGS_RELEASE})
    STRING(REPLACE "/MDd" "/MTd" CMAKE_CXX_FLAGS_DEBUG ${CMAKE_CXX_FLAGS_DEBUG})
endif(WIN32)

set(CMAKE_CXX_STANDARD 20)

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG")

add_compile_definitions(CPPHTTPLIB_OPENSSL_SUPPORT)

file(GLOB source_files "src/*.cpp" "src/*/*.cpp" "src/*/*.hpp" "include/*.h"  "include/*/*.h" "include/*/*/*.h" "include/*.hpp"  "include/*/*.hpp" "include/*/*/*.hpp")
find_package(httplib CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)
find_package(CURL REQUIRED)

add_executable(${PROJECT_NAME} ${source_files})
set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "BeamMP-Launcher")

if (WIN32)
    find_package(ZLIB REQUIRED)
    find_package(OpenSSL REQUIRED)
    target_link_libraries(${PROJECT_NAME} PRIVATE
            ZLIB::ZLIB OpenSSL::SSL OpenSSL::Crypto ws2_32 httplib::httplib nlohmann_json::nlohmann_json CURL::libcurl)
elseif (UNIX)
    find_package(ZLIB REQUIRED)
    find_package(OpenSSL REQUIRED)
    target_link_libraries(${PROJECT_NAME} PRIVATE
            ZLIB::ZLIB OpenSSL::SSL OpenSSL::Crypto CURL::libcurl)
else(WIN32) #MINGW
    add_definitions("-D_WIN32_WINNT=0x0600")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Os -s --static")
    target_link_libraries(${PROJECT_NAME} ssl crypto ws2_32 ssp crypt32 z CURL::libcurl)
endif(WIN32)
target_include_directories(${PROJECT_NAME} PRIVATE "include")

# CPack configuration for .deb packaging
if(UNIX AND NOT APPLE)
    set(CPACK_GENERATOR "DEB")
    set(CPACK_PACKAGE_NAME "beammp-launcher")
    set(CPACK_PACKAGE_VENDOR "BeamMP")
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "BeamMP Launcher for BeamNG.drive")
    set(CPACK_PACKAGE_DESCRIPTION "BeamMP Launcher is the official launcher for the BeamMP mod for BeamNG.drive. It handles downloading the mod, launching the game, and creating connections to servers.")
    set(CPACK_PACKAGE_CONTACT "https://forum.beammp.com")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "BeamMP Community")
    set(CPACK_DEBIAN_PACKAGE_SECTION "games")
    set(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
    set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
    # Runtime dependencies (libcurl and openssl are usually already installed)
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libcurl4 (>= 7.68.0) | libcurl3t64 (>= 7.68.0), libssl3 (>= 3.0.0) | libssl1.1 (>= 1.1.0)")
    # Post-install script to update desktop database
    set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${CMAKE_SOURCE_DIR}/debian/postinst")
    
    # Install the binary to /usr/bin as BeamMP-Launcher (required by the code)
    install(TARGETS ${PROJECT_NAME}
            RUNTIME DESTINATION bin
            COMPONENT Runtime)
    
    # Install desktop file for menu/desktop integration (create if missing)
    set(DESKTOP_FILE "${CMAKE_SOURCE_DIR}/beammp-launcher.desktop")
    if(NOT EXISTS ${DESKTOP_FILE})
        file(WRITE ${DESKTOP_FILE}
"[Desktop Entry]
Version=1.0
Type=Application
Name=BeamMP Launcher
GenericName=BeamMP Launcher
Comment=Launcher for the BeamMP mod for BeamNG.drive
Exec=BeamMP-Launcher
Icon=application-x-executable
Terminal=true
Categories=Game;
Keywords=beammp;beamng;drive;multiplayer;launcher;game;
StartupNotify=false
NoDisplay=false
")
        message(STATUS "Created missing desktop file: ${DESKTOP_FILE}")
    endif()
    install(FILES ${DESKTOP_FILE}
            DESTINATION share/applications
            COMPONENT Runtime)
    
    # Set package version (can be overridden with -DCPACK_PACKAGE_VERSION)
    if(NOT CPACK_PACKAGE_VERSION)
        # Try to get version from git, fallback to 1.0.0
        find_package(Git QUIET)
        if(GIT_FOUND)
            execute_process(
                COMMAND ${GIT_EXECUTABLE} describe --tags --always --dirty
                WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                OUTPUT_VARIABLE GIT_VERSION
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
            )
            if(GIT_VERSION)
                string(REGEX REPLACE "^v" "" CPACK_PACKAGE_VERSION "${GIT_VERSION}")
                # Ensure version starts with a digit (Debian requirement)
                string(SUBSTRING "${CPACK_PACKAGE_VERSION}" 0 1 FIRST_CHAR)
                if(NOT FIRST_CHAR MATCHES "[0-9]")
                    set(CPACK_PACKAGE_VERSION "0.${CPACK_PACKAGE_VERSION}")
                endif()
            else()
                set(CPACK_PACKAGE_VERSION "1.0.0")
            endif()
        else()
            set(CPACK_PACKAGE_VERSION "1.0.0")
        endif()
    endif()
    
    # Architecture detection
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64")
        set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "i[3-6]86")
        set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "i386")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
        set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "arm64")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm")
        set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "armhf")
    else()
        set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE ${CMAKE_SYSTEM_PROCESSOR})
    endif()
    
    include(CPack)
endif()
