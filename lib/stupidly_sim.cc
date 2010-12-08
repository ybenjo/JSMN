#include <iostream>
#include <unordered_map>
#include <string>
#include <vector>
#include <fstream>
#include <algorithm>
#include <math.h>
#include <sstream>

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

//getter
double get_unordered_map_value(unordered_map<int, double> h, int key){
  bool flag = (h.end() != h.find(key));
  if(flag){
    return h[key];
  }else{
    return 0.0;
  }
}

//calc cosine sim
double cosine_sim(const unordered_map<int, double>& h1, const unordered_map<int, double>& h2){
  double norm_1 = 0.0, norm_2 = 0.0, inner = 0.0;
  unordered_map<int, double>::const_iterator i;
  
  for(i = h1.begin(); i != h1.end(); ++i){
    norm_1 += pow(i->second, 2.0);
    inner += get_unordered_map_value(h1, i->first) * get_unordered_map_value(h2, i->first);
  }

  for(i = h2.begin(); i != h2.end(); ++i){
    norm_2 += pow(i->second, 2.0);
  }

  return inner / (pow(norm_1, 0.5) * pow(norm_2, 0.5));
}


int main(int argc, char **argv){
   ifstream ifs;
   string temp;
   vector<string> ret_string;

   unordered_map<int, double> input_bow;
   double sum = 0.0;
   ifs.open(argv[1], ios::in);
   while(ifs && getline(ifs, temp)){
     ret_string = split(temp, " ");

     for(vector<string>::iterator i = ret_string.begin(); i != ret_string.end(); ++i){
       vector<string> feature = split(*i, ":");
       input_bow[atoi(feature[0].c_str())] = atof(feature[1].c_str());
       sum += atof(feature[1].c_str());
     }
   }
   ifs.close();

   for(unordered_map<int, double>::iterator i = input_bow.begin(); i != input_bow.end(); ++i){
     input_bow[i->first] /= sum;
   }

   unordered_map<int, double> score;
   
   ifs.open("../../JSMN_DB/bow_2000_filterd.txt", ios::in);
   while(ifs && getline(ifs, temp)){
     double sum = 0.0;
     ret_string = split(temp, " ");
     int j_id = atoi(ret_string[0].c_str());
     unordered_map<int, double> this_bow;
     for(int i = 1; i < ret_string.size(); ++i){
       vector<string> feature = split(ret_string[i], ":");
       this_bow[atoi(feature[0].c_str())] = atof(feature[1].c_str());
       sum += atof(feature[1].c_str());
     }
     for(unordered_map<int, double>::iterator i = this_bow.begin(); i != this_bow.end(); ++i){
       this_bow[i->first] /= sum;
       //       cout << " " << i->first << ":" << i->second / sum ;
     }
     score[j_id] = cosine_sim(input_bow, this_bow);
     //      cout << " " << score[j_id] << endl;
   }
   ifs.close();
}
