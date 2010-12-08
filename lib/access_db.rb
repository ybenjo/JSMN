require 'tokyocabinet'
require 'tokyotyrant'
require "#{File::expand_path(File::dirname(__FILE__))}/exceptions.rb"
include TokyoTyrant

module AccessDB
  @localhost = "127.0.0.1"
  @word_port = 9998
  @journal_port = 9999
  @bow_port = 10000
  
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
  
  def self.active?
    raise WordDatabaseDownError if !word_db_active?
    raise JournalDatabaseDownError if !journal_db_active?
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
  
end

if $0 == __FILE__
  include AccessDB
end
