#include <iostream>
#include <vector>
#include <thread>
#include "rtmidi/RtMidi.h"

class MidiRouter {
private:
    RtMidiIn midiIn;
    RtMidiOut midiOut;
    static constexpr size_t SLEEP_MS = 10;

    static void midiCallback(double deltaTime, std::vector<unsigned char>* message, void* userData) noexcept {
        if (!message || message->empty() || !userData) return;
        
        try {
            auto* midiOut = static_cast<RtMidiOut*>(userData);
            midiOut->sendMessage(message);
        } catch (...) {
			
        }
    }

    template<typename T>
    static void listDevices(T& midi, const char* type) noexcept {
        const unsigned int nPorts = midi.getPortCount();
        std::cout << "Available MIDI " << type << " ports:\n";
        for (unsigned int i = 0; i < nPorts; ++i) {
            try {
                std::cout << i << ": " << midi.getPortName(i) << '\n';
            } catch (...) {
                std::cout << i << ": <error reading port name>\n";
            }
        }
        std::cout.flush();
    }

    template<typename T>
    static unsigned int selectDevice(T& midi, const char* type) {
        while (true) {
            listDevices(midi, type);
            const unsigned int portCount = midi.getPortCount();
            if (portCount == 0) {
                throw std::runtime_error("No MIDI devices available");
            }

            std::cout << "Select " << type << " port (0 to " << (portCount - 1) << "): ";
            unsigned int deviceIndex;
            if (std::cin >> deviceIndex && deviceIndex < portCount) {
                return deviceIndex;
            }
            
            std::cin.clear();
            std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
            std::cerr << "Invalid port number! Please try again.\n";
        }
    }

public:
    MidiRouter() = default;

    void initialize() {
        const unsigned int inIdx = selectDevice(midiIn, "input");
        const unsigned int outIdx = selectDevice(midiOut, "output");

        midiIn.openPort(inIdx);
        midiOut.openPort(outIdx);

        std::cout << "Routing MIDI input port " << inIdx 
                  << " to output port " << outIdx << "...\n" << std::flush;

        midiIn.setCallback(&midiCallback, &midiOut);
    }

    void run() {
        while (true) {
            std::this_thread::sleep_for(std::chrono::milliseconds(SLEEP_MS));
        }
    }
};

int main() {
    try {
        MidiRouter router;
        router.initialize();
        router.run();
    }
    catch (const RtMidiError& error) {
        std::cerr << "RtMidi error: " << error.getMessage() << '\n';
        return 1;
    }
    catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << '\n';
        return 1;
    }
    catch (...) {
        std::cerr << "Unknown error occurred.\n";
        return 1;
    }
    return 0;
}