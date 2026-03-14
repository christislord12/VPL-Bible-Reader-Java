#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <map>
#include <limits>
#include <dirent.h> // For directory scanning on Unix/Mac

// Structure to hold our data
struct BibleData {
    std::vector<std::string> bookOrder;
    std::map<std::string, std::vector<std::string> > bookMap; // Space between >> for C++98
};

// Helper to trim whitespace (C++98 style)
std::string trim(const std::string& s) {
    if (s.empty()) return s;
    size_t first = s.find_first_not_of(" \t\r\n");
    if (first == std::string::npos) return "";
    size_t last = s.find_last_not_of(" \t\r\n");
    return s.substr(first, (last - first + 1));
}

// Check if string ends with suffix
bool hasSuffix(const std::string& str, const std::string& suffix) {
    if (str.length() >= suffix.length()) {
        return (0 == str.compare(str.length() - suffix.length(), suffix.length(), suffix));
    }
    return false;
}

BibleData parseVplFile(const std::string& filePath) {
    BibleData data;
    std::ifstream file(filePath.c_str()); // .c_str() required for C++98 fstream
    std::string line;

    if (!file.is_open()) {
        std::cerr << "Error: Could not open file " << filePath << std::endl;
        return data;
    }

    while (std::getline(file, line)) {
        if (line.length() < 4) continue;

        std::string bookId = trim(line.substr(0, 3));

        // In C++98, we check existence using find()
        if (data.bookMap.find(bookId) == data.bookMap.end()) {
            data.bookOrder.push_back(bookId);
        }
        data.bookMap[bookId].push_back(line);
    }
    return data;
}

void displayMenu(const std::vector<std::string>& items, const std::string& title) {
    std::cout << "\n--- " << title << " ---\n";
    for (size_t i = 0; i < items.size(); ++i) {
        std::cout << i + 1 << ". " << items[i] << "\n";
    }
    std::cout << "0. Exit/Back\n";
    std::cout << "Selection: ";
}

int main() {
    std::string bibleDir = "./bibles";
    std::vector<std::string> vplFiles;

    // 1. Scan for files using dirent.h (C-style)
    DIR *dir;
    struct dirent *ent;
    if ((dir = opendir(bibleDir.c_str())) != NULL) {
        while ((ent = readdir(dir)) != NULL) {
            std::string fileName = ent->d_name;
            if (hasSuffix(fileName, ".txt")) {
                vplFiles.push_back(fileName);
            }
        }
        closedir(dir);
    } else {
        std::cerr << "Error: Could not open directory " << bibleDir << std::endl;
        return 1;
    }

    if (vplFiles.empty()) {
        std::cerr << "No .txt files found in " << bibleDir << "\n";
        return 1;
    }

    while (true) {
        displayMenu(vplFiles, "Select a Bible Version");
        int fileChoice;
        if (!(std::cin >> fileChoice)) {
            std::cin.clear();
            std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
            continue;
        }

        if (fileChoice == 0) break;
        if (fileChoice < 1 || fileChoice > (int)vplFiles.size()) continue;

        std::string selectedFile = vplFiles[fileChoice - 1];
        BibleData currentBible = parseVplFile(bibleDir + "/" + selectedFile);

        while (true) {
            displayMenu(currentBible.bookOrder, "Select a Book (" + selectedFile + ")");
            int bookChoice;
            if (!(std::cin >> bookChoice)) {
                std::cin.clear();
                std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
                continue;
            }

            if (bookChoice == 0) break;
            if (bookChoice < 1 || bookChoice > (int)currentBible.bookOrder.size()) continue;

            std::string selectedBook = currentBible.bookOrder[bookChoice - 1];
            std::cout << "\n=== " << selectedBook << " ===\n";
            
            // C++98 Iterator instead of range-based for loop
            std::vector<std::string>& verses = currentBible.bookMap[selectedBook];
            for (std::vector<std::string>::iterator it = verses.begin(); it != verses.end(); ++it) {
                std::cout << *it << "\n";
            }

            std::cout << "\n(End of " << selectedBook << ")\n";
            std::cout << "Press Enter to return...";
            std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
            std::cin.get();
        }
    }

    return 0;
}
