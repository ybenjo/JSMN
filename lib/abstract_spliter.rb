# -*- coding: utf-8 -*-
require "digest/md5"
require "#{File::expand_path(File::dirname(__FILE__))}/exceptions.rb"
require "#{File::expand_path(File::dirname(__FILE__))}/access_db.rb"
include AccessDB

$KCODE = "u"
ABST_LENGTH = 1000
DATA_PATH = "/tmp"

#Classes
class AbstractSpliter
  attr_reader :abst, :abst_md5, :filterd_abst, :bag_of_words
  def initialize(abst)
    @abst = abst.split(//)[0..(ABST_LENGTH - 1)].join("")
    set_abst_md5
  end

  def set_abst_md5
    @abst_md5 = Digest::MD5.new.update(@abst + Time.now.to_s).to_s
  end

  def filter_alphabet
    @filterd_abst = @abst.gsub(/\n/, "").gsub(/[^a-zA-Z]/, " ").gsub(/(\s{2,})/," ").gsub(/^\s|\s$/, "").downcase
  end

  def set_bag_of_words
    filterd_abst_ary = @filterd_abst.split(" ")

    #3文字未満の単語は削除
    filterd_abst_ary.delete_if{|w|w.size < 3}
    
    raise ShortAbstractError if filterd_abst_ary.size < 1
    @bag_of_words = Hash.new{0}
    filterd_abst_ary.each do |w|
      @bag_of_words[w] += 1
    end
  end

  def write_bag_of_words
    open("#{DATA_PATH}/jsmn_#{@abst_md5}", "w"){|f|
      tmp = []
      @bag_of_words.each_pair do |k, v|
        value = AccessDB.get_word_id(k)
        tmp.push "#{value}:#{v}" if !value.nil?
      end
      f.puts tmp.join(" ")
    }
  end

  def delete_bag_of_words
    `rm -f #{DATA_PATH}/jsmn_#{@abst_md5}` if File.exists?("#{DATA_PATH}/jsmn_#{@abst_md5}")
    `rm -f #{DATA_PATH}/jsmn_#{@abst_md5}.out` if File.exists?("#{DATA_PATH}/jsmn_#{@abst_md5}.out")
  end
end

if $0 == __FILE__
end
