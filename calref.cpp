//#include "file.h"
#include <fstream>
#include <iostream>
#include <string>
//#include <string.h>
#include <mutex>
#include <vector>
#include <thread>
//#include <chrono>
#include <unordered_map>

std::mutex mtx;
std::unordered_map<int, int> map;
//const auto processor_count = std::thread::hardware_concurrency();

std::vector<std::string> load_filenames(const char* file_name) {
	std::vector<std::string> filenames;
	std::ifstream file(file_name);
	std::string line;
	while(std::getline(file, line)) filenames.push_back(line);
	file.close();
	return filenames;
}

void count_PMIDs(std::string filename) {
	std::ifstream file(filename);
	std::unordered_map<int, int> submap;
	std::string line;
	while (std::getline(file, line)) {
		++submap[std::stoi(line)];
	}
	for (std::unordered_map<int, int>::iterator it = submap.begin(); it != submap.end(); it++) {
		mtx.lock();
		map[it->first] += it->second;
		mtx.unlock();
	}
}
/*
void count_PMIDs(const char* file_name) {
	std::ifstream file(file_name);
	//std::size_t lines_count = 0;
	std::string line;
	while(std::getline(file, line)) {
		//++lines_count;
		++map[std::stoi(line)];
		//std::cout << line << std::endl;
	}
	file.close();
}
*/
void save(const char* file_name) {
	std::ofstream file(file_name);
	for(std::unordered_map<int, int>::iterator it = map.begin(); it != map.end(); it++){
		//fwrite(&(iter->first), 4, 4, f); // sizeof(int) = 1
		//fwrite(&(iter->second), 4, 4, f);
		file << it->first << "\t" << it->second << std::endl;
	}
	file.close();
}

void show_filenames(std::vector<std::string> filenames) {
	for (std::string i : filenames) std::cout << i << std::endl;
}

void threadprocess(std::vector<std::string> filenames) {
	std::vector<std::thread> threads;
	for (int i = 0; i < filenames.size(); i++) {
		//cout << filenames[i] << endl;
		threads.push_back(std::thread(count_PMIDs, filenames[i]));
	}
	for (auto &th : threads) th.join();
}

int main(int argc, char* argv[]) {
	//std::vector<std::string> all_args;
	//if (argc > 1) all_args.assign(argv, argv + argc);
	std::vector<std::string> filenames = load_filenames(argv[1]); // argv[1] is the file which contain all input filenames
	//show_filenames(filenames);
	//auto start = std::chrono::system_clock::now();
	//count_PMIDs(argv[1]);
	threadprocess(filenames);
	//auto end = std::chrono::system_clock::now();
	//auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
	//std::cout << "Time cost:" << double(duration.count()) << std::endl;
	save(argv[2]); // argv[2] is the output file
	return 0;
}

