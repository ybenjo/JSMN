# -*- coding: utf-8 -*-
require 'tokyocabinet'
require 'tokyotyrant'
require "#{File::expand_path(File::dirname(__FILE__))}/exceptions.rb"
include TokyoTyrant

module AccessDB
  @localhost = "127.0.0.1"
  @word_port = 9998
  @journal_port = 9999
  @bow_port = 10000
  @mutual_info_port = 9997
  
  def self.get_word_id(word)
    rdb = RDBTBL::new
    flag = rdb.open(@localhost, @word_port)
    raise WordDatabaseDownError if !flag

    tmp_v = rdb.get(word)
    id = nil
    if !tmp_v.nil?
      id = tmp_v["id"]
    end
    rdb.close
    return id
  end
  
  def self.get_journal_id(journal)
    rdb = RDBTBL::new
    flag = rdb.open(@localhost, @journal_port)
    raise JournalDatabaseDownError if !flag
    
    id = rdb.get(journal)["id"]
    rdb.close
    return id
  end

  def self.get_bow(j_id)
    rdb = RDB::new
    flag = rdb.open(@localhost, @bow_port)
    raise BOWDatabaseDownError if !flag
    
    bow = Marshal.load(rdb.get(j_id))
    rdb.close
    return bow
  end

  def self.get_word_string(w_id)
    rdb = RDBTBL::new
    rdb.open(@localhost, @word_port)
    qry = RDBQRY::new(rdb)
    qry.addcond("id", RDBQRY::QCSTREQ, w_id.to_s)
    ret_str = qry.search().first
    rdb.close
    return ret_str
  end

  def self.get_journal_string(j_id)
    rdb = RDBTBL::new
    rdb.open(@localhost, @journal_port)
    qry = RDBQRY::new(rdb)
    qry.addcond("id", RDBQRY::QCSTREQ, j_id.to_s)
    ret_str = qry.search().first
    rdb.close
    return ret_str
  end

  def self.word_db_active?
    rdb = RDBTBL::new
    flag = rdb.open(@localhost, @word_port)
    rdb.close
    return flag
  end
  
  def self.journal_db_active?
    rdb = RDBTBL::new
    flag = rdb.open(@localhost, @journal_port)
    rdb.close
    return flag
  end
  
  def self.mutual_info_db_active?
    rdb = RDBTBL::new
    flag = rdb.open(@localhost, @mutual_info_port)
    rdb.close
    return flag
  end
  
  def self.active?
    raise WordDatabaseDownError if !word_db_active?
    raise JournalDatabaseDownError if !journal_db_active?
    raise MutualInformationDatabaseDownError if !mutual_info_db_active?
    return true
  end

  def self.convert_bag_of_words_to_id(bow)
    ret = Hash.new{0}
    bow.each_pair do |w, count|
      id = get_word_id(w)
      ret[id.to_i] = count if !id.nil?
    end
    return ret
  end
  

  
  #input
  #bow => {w_id => count, w_id => count, ...}
  #journal_list => [j_id, j_id, j_id, ...]

  #output
  #ret = {j_id => [word, word, word], j_id => [word, word, word] }
  #ジャーナルごとに相互情報量のランキングを取得し、
  #相互情報量が大きい順　かつ bowに含まれた単語を返す
  def self.set_top3_mutual_info(bow, journal_list)
    rdb = RDB::new
    flag = rdb.open(@localhost, @mutual_info_port)

    ret = Hash.new
    
    journal_list.each do |j_id|
      tmp = Hash.new
      m_info = Marshal.load(rdb.get(j_id))
      p m_info
      bow.each_key do |w_id|
        tmp[w_id] = m_info[w_id].to_i
      end
      ret[j_id] = []
      tmp.to_a.sort{|a,b|b[1] <=> a[1]}[0..2].each{|e| ret[j_id].push e[0]}
    end
    return ret
    rdb.close
  end
end

if $0 == __FILE__
  include AccessDB
end
