#include <iostream>
#include <string>
#include <vector>
#include <fstream>
#include <algorithm>
#include <math.h>
#include <sstream>
#include <map>
#include <unordered_map>

using namespace std;

//split
vector<string> split(const string& s, const string& c){
  vector<string> ret;
  for(int i = 0, n; i <= s.length(); i = n + 1){
    n = s.find_first_of(c, i);
    if(n == string::npos) n = s.length();
    string tmp = s.substr(i, n-i);
    ret.push_back(tmp);
  }
  return ret;
}

struct myeq : std::binary_function<pair<int, int>, pair<int, int>, bool>{
  bool operator() (const pair<int, int> & x, const pair<int, int> & y) const{
    return x.first == y.first && x.second == y.second;
  }
};

struct myhash : std::unary_function<pair<int, int>, size_t>{
private:
  const hash<int> h_int;
public:
  myhash() : h_int() {}
  size_t operator()(const pair<int, int> & p) const{
    size_t seed = h_int(p.first);
    return h_int(p.second) + 0x9e3779b9 + (seed<<6) + (seed>>2);
  }
};

double log_2(double x){
  if(x == 0){
    return 0.0;
  }else if(isnan(x)){
    return 0.0;
  }else{
    return log(x) / log(2);
  }
}

int main(int argc, char **argv){
   ifstream ifs;
   string temp;
   vector<string> ret_string;

   //unordered_map<pair<int, int>, int, myhash, myeq> n;
   unordered_map<int, unordered_map<int, int> > n;
   int document_size = 0;
   int word_size = 0;
   unordered_map<int, int> journal_count;
   unordered_map<int, int> word_count;

   map<int, vector<int> > input_bow;
   vector<int> all_words;

   //input data type
   //doc_id \s journal_id \s year \ features< word_id:count \s word_id:count>
   //ifs.open("../../JSMN_DB/bow.txt", ios::in);
   ifs.open(argv[1], ios::in);
   while(ifs && getline(ifs, temp)){
     ret_string = split(temp, " ");
     int j_id = atoi(ret_string[1].c_str());
     document_size++;
     cout << document_size << endl;
     journal_count[j_id]++;
     for(int i = 3; i < ret_string.size(); ++i){
       vector<string> feature = split(ret_string[i], ":");
       int w_id = atoi(feature[0].c_str());
       all_words.push_back(w_id);
       n[j_id][w_id]++;
       word_count[w_id]++;
       word_size++;
     }
   }
   ifs.close();

   sort(all_words.begin(), all_words.end());
   all_words.erase( unique( all_words.begin(), all_words.end() ), all_words.end());

   ostringstream oss;
   oss << argv[1] << ".mutual_info";
   ofstream ofs;
   ofs.open((oss.str()).c_str());

   unordered_map<int, unordered_map<int, int> >::iterator x;
   for(x = n.begin(); x != n.end(); ++x){
     int j_id = x->first;

     multimap<double, int> mutual_info;

     unordered_map<int, int>::iterator i;
     for(i = x->second.begin(); i != x->second.end(); ++i){
       //calc mutual information(j_id, w_id)
       int w_id = i->first;
       
       double n_11 = i->second;
       double n_10 = word_count[w_id] - n_11;
       double n_01 = journal_count[j_id] - n_11;
       double n_00 = document_size - journal_count[j_id] - n_10;

       double n_0x = n_00 + n_01;
       double n_x0 = n_00 + n_10;
       double n_1x = n_10 + n_11;
       double n_x1 = n_01 + n_11;

       double s_1 = (n_11 / document_size) * log_2( (document_size * n_11) / (n_1x * n_x1) );
       double s_2 = (n_01 / document_size) * log_2( (document_size * n_01) / (n_0x * n_x1) );
       double s_3 = (n_10 / document_size) * log_2( (document_size * n_10) / (n_1x * n_x0) );
       double s_4 = (n_00 / document_size) * log_2( (document_size * n_00) / (n_0x * n_x0) );

       double score = s_1 + s_2 + s_3 + s_4;
       mutual_info.insert(make_pair(score, w_id));
     }

     for(multimap<double, int>::reverse_iterator i = mutual_info.rbegin(); i != mutual_info.rend(); ++i){
       ofs << j_id << "," << i->second << "," << i->first << endl;
     }
   }
   
   ofs.close();
}
