#include <iostream>
#include <csignal>
#include <atomic>
#include <chrono>
#include <thread>

std::atomic<bool> keepRunning(true);

void signalHandler(int signum) {
    // Signal handler to set the atomic flag to false
    keepRunning = false;
}

int main() {
    // Register signal handlers for SIGINT and SIGTERM
    std::signal(SIGINT, signalHandler);
    std::signal(SIGTERM, signalHandler);

    std::cout << "Program 2 running on boot";

    int counter = 0;

    while (keepRunning) {
        std::cout << "Seconds unix time: " << std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count() / 1e9 << std::endl;
        // Wait for 1 second
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }

    std::cout << "Signal received. Exiting program." << std::endl;
    return 0;
}
