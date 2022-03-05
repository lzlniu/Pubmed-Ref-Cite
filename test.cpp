#include <iostream>
#include <vector>
#include <thread>

using namespace std;

int sum = 0;

void add(int n) { sum += n; }
 
int main() {
  vector<int> s = {2,3,7,1,9,5,124,657,3232,12,66};
  vector<thread> threads;
  cout << sum << endl; 

  for (int i = 0; i < s.size(); i++) {
    threads.push_back(thread(add, s[i]));
  }
 
  for (auto &th : threads) {
    th.join();
  }
  cout << sum << endl;  

  return 0;
}
