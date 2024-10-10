#include <iostream>
#include <vector>
#include <thread>
#include "rtmidi/RtMidi.h"

void listMidiInDevices(RtMidiIn &midiIn) {
    unsigned int nPorts = midiIn.getPortCount();
    std::cout << "Available MIDI input ports:\n";
    for (unsigned int i = 0; i < nPorts; ++i) {
        std::string portName = midiIn.getPortName(i);
        std::cout << i << ": " << portName << std::endl;
    }
}

void listMidiOutDevices(RtMidiOut &midiOut) {
    unsigned int nPorts = midiOut.getPortCount();
    std::cout << "Available MIDI output ports:\n";
    for (unsigned int i = 0; i < nPorts; ++i) {
        std::string portName = midiOut.getPortName(i);
        std::cout << i << ": " << portName << std::endl;
    }
}

void midiCallback(double deltaTime, std::vector<unsigned char> *message, void *userData) {
    RtMidiOut *midiOut = static_cast<RtMidiOut *>(userData);
    if (message->size() > 0) {
        midiOut->sendMessage(message);
    }
}

unsigned int selectMidiInput(RtMidiIn &midiIn) {
    unsigned int inputDeviceIndex;
    while (true) {
        listMidiInDevices(midiIn);
        std::cout << "Select a MIDI input port (0 to " << (midiIn.getPortCount() - 1) << "): ";
        std::cin >> inputDeviceIndex;

        if (inputDeviceIndex < midiIn.getPortCount()) {
            return inputDeviceIndex;
        } else {
            std::cerr << "Invalid port number! Please try again." << std::endl;
        }
    }
}

unsigned int selectMidiOutput(RtMidiOut &midiOut) {
    unsigned int outputDeviceIndex;
    while (true) {
        listMidiOutDevices(midiOut);
        std::cout << "Select a MIDI output port (0 to " << (midiOut.getPortCount() - 1) << "): ";
        std::cin >> outputDeviceIndex;

        if (outputDeviceIndex < midiOut.getPortCount()) {
            return outputDeviceIndex;
        } else {
            std::cerr << "Invalid port number! Please try again." << std::endl;
        }
    }
}

int main() {
    try {
        RtMidiIn midiIn;
        RtMidiOut midiOut;

        unsigned int inputDeviceIndex = selectMidiInput(midiIn);
        midiIn.openPort(inputDeviceIndex);
        std::cout << "Listening on MIDI input port " << inputDeviceIndex << "...\n";

        unsigned int outputDeviceIndex = selectMidiOutput(midiOut);
        midiOut.openPort(outputDeviceIndex);
        std::cout << "Routing MIDI input to output port " << outputDeviceIndex << "...\n";

        midiIn.setCallback(&midiCallback, &midiOut);

        while (true) {
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
        }
    } catch (RtMidiError &error) {
        error.printMessage();
        return 1;
    } catch (const std::exception &e) {
        std::cerr << "Exception: " << e.what() << std::endl;
        return 1;
    } catch (...) {
        std::cerr << "Unknown error occurred." << std::endl;
        return 1;
    }

    return 0;
}
