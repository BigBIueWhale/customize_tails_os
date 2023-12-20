#include <iostream>
#include <csignal>
#include <atomic>
#include <chrono>
#include <thread>

std::atomic<bool> keepRunning(true);

void signalHandler(int signum) {
    static_cast<void>(signum);
    // Signal handler to set the atomic flag to false
    keepRunning = false;
}

int main() {
    // Register signal handlers for SIGINT and SIGTERM
    std::signal(SIGINT, signalHandler);
    std::signal(SIGTERM, signalHandler);

    std::cout << "Program 1 running on boot" << std::endl;

    int counter = 0;

    while (keepRunning) {
        std::cout << "Counter value: " << counter++ << std::endl;
        // Wait for 1 second
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }

    std::cout << "Signal received. Exiting program." << std::endl;
    return 0;
}
