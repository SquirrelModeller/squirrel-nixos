#include <iostream>
#include <fstream>
#include <string>
#include <thread>
#include <chrono>
#include <sstream>
#include <iomanip>

double getCPUUsage() {
    static long prevIdleTime = 0, prevTotalTime = 0;
    long idleTime, totalTime;

    std::ifstream statFile("/proc/stat");
    std::string line;

    if (statFile.is_open() && std::getline(statFile, line)) {
        std::istringstream iss(line);
        std::string cpu;
        long user, nice, system, idle, iowait, irq, softirq, steal;

        // Number reference:
        // https://www.man7.org/linux/man-pages/man5/proc_stat.5.html
        iss >> cpu >> user >> nice >> system >> idle >> iowait >> irq >> softirq >> steal;

        idleTime = idle + iowait;
        totalTime = user + nice + system + idle + iowait + irq + softirq + steal;

        long deltaIdle = idleTime - prevIdleTime;
        long deltaTotal = totalTime - prevTotalTime;

        prevIdleTime = idleTime;
        prevTotalTime = totalTime;

        return deltaTotal ? (1.0 - (double)deltaIdle / deltaTotal) * 100.0 : 0.0;
    }
    return 0.0;
}

double getRAMUsage() {
    std::ifstream memInfoFile("/proc/meminfo");
    std::string line;
    long totalMemory = 0, freeMemory = 0;

    if (memInfoFile.is_open()) {
        while (std::getline(memInfoFile, line)) {
            std::istringstream iss(line);
            std::string key;
            long value;
            std::string unit;

            iss >> key >> value >> unit;

            if (key == "MemTotal:") {
                totalMemory = value;
            } else if (key == "MemAvailable:") {
                freeMemory = value;
                break;
            }
        }
    }
    return totalMemory ? ((double)(totalMemory - freeMemory) / totalMemory) * 100.0 : 0.0;
}

int main() {
    while (true) {
        double cpuUsage = getCPUUsage();
        double ramUsage = getRAMUsage();

        std::cout << std::fixed << std::setprecision(2);
        std::cout << cpuUsage << " " << ramUsage << std::endl;

        std::this_thread::sleep_for(std::chrono::milliseconds(1000));
    }
    return 0;
}
