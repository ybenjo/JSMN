#include <iostream>
#include <unordered_map>
#include <fstream>
#include <sstream>
#include <string>
#include <algorithm>
#include <vector>

using namespace std;

vector<string> split(const string& s, const string& c){
  vector<string> ret;
  for(int i = 0, n = 0; i <= s.length(); i = n + 1){
    n = s.find_first_of(c, i);
    if(n == string::npos) n = s.length();
    string tmp = s.substr(i, n-i);
    ret.push_back(tmp);
  }
  return ret;
}

void set_dictionary(unordered_map<string, int>& dic, const string& key){
  if(dic.end() == dic.find(key)){
    dic[key] = dic.size();
  }
}

void join(string& ret, const vector<string>& vec, const string& sep){
  ostringstream oss;
  for(vector<string>::const_iterator i = vec.begin(); i != vec.end(); ++i){
    if(i == vec.begin()){
      oss << *i;
    }else{
      oss << sep << *i;
    }
  }
  ret = oss.str();
}

int main(int argc, char **argv){
  ifstream ifs;
  string tmp;
  vector<string> ret_str;
  unordered_map<string, int> word_dic;
  unordered_map<string, int> journal_dic;
  
  ifs.open("../text/prev/smart_stopwords_filterd.txt", ios::in);
  while(ifs && getline(ifs, tmp)){
    set_dictionary(word_dic, tmp);
  }
  ifs.close();

  const int stopwords_max = word_dic.size() - 1;

  ofstream ofs;
  ostringstream oss;
  oss << argv[1] << ".bow";
  ofs.open(const_cast<char*>(oss.str().c_str()));

  ifs.open(argv[1], ios::in);
  while(ifs && getline(ifs, tmp)){
    unordered_map<int, int> each_paper;
    ret_str = split(tmp, "\t");
    set_dictionary(journal_dic, ret_str[1]);
    int j_id = journal_dic[ret_str[1]];

    //
    vector<string> words = split(ret_str[3], " ");
    for(vector<string>::iterator i = words.begin(); i != words.end(); ++i){
      set_dictionary(word_dic, *i);
      int w_id = word_dic[*i];
      if(w_id > stopwords_max){
	each_paper[w_id] += 1;
      }
    }

    //
    string paper;
    vector<string> p_tmp;
    for(unordered_map<int, int>::iterator i = each_paper.begin(); i != each_paper.end(); ++i){
      ostringstream oss;
      oss << i->first << ":" << i->second;
      p_tmp.push_back(oss.str());
    }
    join(paper, p_tmp, " ");
    ofs << ret_str[0] << " " << j_id << " " << ret_str[2] << " " << paper << endl;
  }
  ifs.close();
  ofs.close();


  ostringstream oss_word_id;
  oss_word_id << argv[1] << ".word_id";
  ofs.open(const_cast<char*>(oss_word_id.str().c_str()));
  for(unordered_map<string, int>::iterator i = word_dic.begin(); i != word_dic.end(); ++i){
    if(i->second > stopwords_max){
      ofs << i->first << "," << i->second << endl;
    }
  }
  ofs.close();

  ostringstream oss_j_id;
  oss_j_id << argv[1] << ".journal_id";
  ofs.open(const_cast<char*>(oss_j_id.str().c_str()));
  for(unordered_map<string, int>::iterator i = journal_dic.begin(); i != journal_dic.end(); ++i){
    ofs << i->first << "," << i->second << endl;
  }
  ofs.close();
}


