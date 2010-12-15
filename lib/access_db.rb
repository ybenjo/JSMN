# -*- coding: utf-8 -*-
require 'tokyocabinet'
require 'tokyotyrant'
require "#{File::expand_path(File::dirname(__FILE__))}/exceptions.rb"
include TokyoTyrant

module AccessDB
  @localhost = "127.0.0.1"
  @word_id_port = 9998
  @id_word_port = 9996
  @journal_port = 9999
  @bow_port = 10000
  @mutual_info_port = 9997

  #関連単語出力
  @lim_size = 5
  
  def self.get_word_id(word)
    rdb = RDB::new
    flag = rdb.open(@localhost, @word_id_port)
    raise WordDatabaseDownError if !flag

    id = rdb.get(word)
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
    rdb = RDB::new
    rdb.open(@localhost, @id_word_port)
    ret_str = rdb.get(w_id)
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
    flag = rdb.open(@localhost, @word_id_port)
    rdb.close
    return flag
  end
  
  def self.journal_db_active?
    rdb = RDBTBL::new
    flag = rdb.open(@localhost, @journal_port)
    rdb.close
    return flag
  end

  def self.id_word_db_active?
    rdb = RDBTBL::new
    flag = rdb.open(@localhost, @id_word_port)
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
    raise IDWordDatabaseDownError if !id_word_db_active?
    raise JournalDatabaseDownError if !journal_db_active?
    raise MutualInformationDatabaseDownError if !mutual_info_db_active?
    return true
  end

  def self.convert_bag_of_words_to_id(bow)
    ret = Hash.new{0}

    rdb = RDB::new
    flag = rdb.open(@localhost, @word_id_port)
    raise WordDatabaseDownError if !flag

    bow.each_pair do |w, count|
      id = rdb.get(w)
      ret[id.to_i] = count if !id.nil?
    end
    rdb.close
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
    rase MutualInformationDatabaseDownError if !flag

    ret = Hash.new
    
    journal_list.each do |j_id|
      tmp = Hash.new
      p rdb.get(j_id)
      m_info = Marshal.load(rdb.get(j_id))
      bow.each_key do |w_id|
        tmp[w_id] = m_info[w_id].to_i
      end
      ret[j_id] = Array.new
      tmp.to_a.sort{|a,b|b[1] <=> a[1]}[0..@lim_size - 1].each{|e| ret[j_id].push e[0]}
    end
    rdb.close
    return ret
  end


  # input [w_id, w_id, w_id...,]
  # output [string, string, string]
  def self.get_word_ids_string(word_ids_ary)
    rdb = RDB::new
    flag = rdb.open(@localhost, @id_word_port)
    raise IDWordDatabaseDownError if !flag

    ret = [ ]

    word_ids_ary.each do |w_id|
      ret.push rdb.get(w_id)
    end
    rdb.close
    return ret
  end
  
end

if $0 == __FILE__
  include AccessDB
end
