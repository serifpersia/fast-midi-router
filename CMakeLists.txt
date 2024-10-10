cmake_minimum_required(VERSION 3.25)
project(MIDIRouter LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)

set(BUILD_TESTS OFF CACHE BOOL "Disable building tests")
set(BUILD_EXAMPLES OFF CACHE BOOL "Disable building examples")

set(RTMIDI_BUILD_TESTING OFF CACHE BOOL "Disable building RtMidi tests")
set(RTMIDI_BUILD_EXAMPLES OFF CACHE BOOL "Disable building RtMidi examples")

set(ENABLE_ALSA OFF CACHE BOOL "Disable ALSA support")
set(ENABLE_JACK OFF CACHE BOOL "Disable JACK support")

include(FetchContent)

FetchContent_Declare(
    rtmidi
    GIT_REPOSITORY https://github.com/thestk/rtmidi.git
)
FetchContent_MakeAvailable(rtmidi)

add_executable(MIDIRouter main.cpp)
target_link_libraries(MIDIRouter PRIVATE rtmidi)
add_custom_command(TARGET MIDIRouter POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy "$<TARGET_FILE:rtmidi>" "$<TARGET_FILE_DIR:MIDIRouter>"
)
