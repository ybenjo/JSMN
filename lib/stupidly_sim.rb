# -*- coding: utf-8 -*-
require "#{File::expand_path(File::dirname(__FILE__))}/access_db.rb"
require "#{File::expand_path(File::dirname(__FILE__))}/abstract_spliter.rb"
include AccessDB

def calc_cosine_sim(h1, h2)
  norm_1 = Math.sqrt(h1.values.inject(0.0){|s,v|s += v**2})
  norm_2 = Math.sqrt(h2.values.inject(0.0){|s,v|s += v**2})
  inner = (h1.keys & h2.keys).inject(0.0){|s,v|s += h1[v] * h2[v]}
  return inner / (norm_1 * norm_2)
end

def stupidly_sim(q_bow)
  puts "Start stupidly_sim"
  rdb = RDB::new
  flag = rdb.open("127.0.0.1", 10000)
  sim = Hash.new
  counter = 1
  raise BOWDatabaseDownError if !flag
  rdb.each_pair do |j_id, bow|
    bow = Marshal.load(bow)
    sim[j_id] = calc_cosine_sim(q_bow, bow)
    p counter;counter += 1
  end
  rdb.close
  return sim
end


if $0 == __FILE__
  # http://www.ncbi.nlm.nih.gov/pubmed/21089180
  text =<<"EOS"
  Inactivation of epidermal growth factor receptor (EGFR) is a prime method used in colon cancer therapy.Here it is shown that chrysophanic acid, a natural anthraquinone, has anticancer activity in EGFR-overexpressing SNU-C5 human colon cancer cells. Chrysophanic acid preferentially blocked proliferation in SNU-C5 cells but not in other cell lines (HT7, HT29, KM12C, SW480, HCT116 and SNU-C4) with low levels of EGFR expression. Chrysophanic acid treatment in SNU-C5 cells inhibited EGF-induced phosphorylation of EGFR and suppressed activation of downstream signaling molecules, such as AKT, extracellular signal-regulated kinase (ERK) and the mammalian target of rapamycin (mTOR)/ribosomal protein S6 kinase (p70S6K). Chrysophanic acid (80 and 120 µm) significantly blocked cell proliferation when combined with the mTOR inhibitor, rapamycin. These findings offer the first evidence of anticancer activity for chrysophanic acid via EGFR/mTOR mediated signaling transduction pathway.
EOS
  
  n = AbstractSpliter.new(text)
  n.filter_alphabet;n.set_bag_of_words
  abst = AccessDB.convert_bag_of_words_to_id(n.bag_of_words)
  sum = abst.values.inject(0.0){|s,v|s+=v}
  abst.each_key{|k|abst[k] /= sum}

  sim = stupidly_sim(abst)
  top_10 = sim.to_a.sort{|a,b|b[1] <=> a[1]}[0..9]
  top_10.each do |e|
    id, score = e
    puts "(#{id}): #{AccessDB.get_journal_string(id)} => #{score}"
  end
end
