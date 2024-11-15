cmake_minimum_required(VERSION 3.15)
project(MIDIRouter VERSION 1.0.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Build type configuration
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

# Include directories
include_directories(${CMAKE_SOURCE_DIR}/rtmidi)

# Platform-specific configurations
if(WIN32)
    add_definitions(-D__WINDOWS_MM__)
    set(MIDI_LIBS winmm)
    
    # MinGW-specific settings
    if(MINGW)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static -static-libgcc -static-libstdc++")
    endif()
elseif(APPLE)
    add_definitions(-D__MACOSX_CORE__)
    set(MIDI_LIBS "-framework CoreMIDI" "-framework CoreAudio" "-framework CoreFoundation")
elseif(UNIX)
    find_package(ALSA QUIET)
    if(ALSA_FOUND)
        add_definitions(-D__LINUX_ALSA__)
        set(MIDI_LIBS asound pthread)
    else()
        add_definitions(-D__UNIX_JACK__)
        set(MIDI_LIBS jack pthread)
    endif()
endif()

# Add RtMidi library
add_library(rtmidi STATIC
    ${CMAKE_SOURCE_DIR}/rtmidi/RtMidi.cpp
    ${CMAKE_SOURCE_DIR}/rtmidi/rtmidi_c.cpp
)

# Main executable
add_executable(MIDIRouter main.cpp)
target_link_libraries(MIDIRouter PRIVATE rtmidi ${MIDI_LIBS})

# Output directory configuration
set_target_properties(MIDIRouter PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}"
)