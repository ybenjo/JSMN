# -*- coding: utf-8 -*-
require "digest/md5"
require "#{File::expand_path(File::dirname(__FILE__))}/exceptions.rb"
require "#{File::expand_path(File::dirname(__FILE__))}/access_db.rb"
include AccessDB

$KCODE = "u"
DATA_PATH = "/tmp"

#Classes
class AbstractSpliter
  attr_reader :abst, :abst_md5, :filterd_abst, :bag_of_words
  def initialize(abst)
    @abst = abst
    set_abst_md5
  end

  def set_abst_md5
    @abst_md5 = Digest::MD5.new.update(@abst + Time.now.to_s).to_s
  end

  def filter_alphabet
    tmp = []
    abst_ary = @abst.gsub(/\(|\)|\{|\}/, " ").downcase.split(" ")
    abst_ary.each do |e|
      if e =~ /[a-z]/
        if e =~ /[0-9]/
          tmp.push e.sub(/[\.,]{1,}$/, "")
        else
          tmp.push e.gsub(/[^a-z]/," ")
        end
      end
    end
    @filterd_abst = tmp.join(" ").gsub(/(\s{2,})/," ").gsub(/^\s|\s$/, "")
  end
  
  def set_bag_of_words
    filterd_abst_ary = @filterd_abst.split(" ")

    # filterd_abst_ary.delete_if{|w|w.size < 3}
    
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
      raise ShortAbstractError if tmp.size < 2
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
