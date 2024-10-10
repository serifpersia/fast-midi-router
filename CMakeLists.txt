cmake_minimum_required(VERSION 3.25)
project(MIDIRouter LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_PREFIX_PATH "C:\\Users\\serif-pc-10\\Documents\\GitHub\\midi-router\\rtmidi")

find_package(RtMidi REQUIRED)

add_executable(MIDIRouter main.cpp)

target_link_libraries(MIDIRouter PRIVATE RtMidi::rtmidi)

add_custom_command(TARGET MIDIRouter POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy 
    "$<TARGET_FILE:RtMidi::rtmidi>" 
    "$<TARGET_FILE_DIR:MIDIRouter>"
)

add_custom_target(clean-all
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}
    COMMENT "Cleaning the build directory..."
)