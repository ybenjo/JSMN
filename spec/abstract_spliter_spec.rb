# -*- coding: utf-8 -*-
require '../lib/abstract_spliter.rb'

describe AbstractSpliter do
  describe "filter_alphabet" do
    it "アルファベット以外の文字列を空白に置換して文末の空白も消してdowncaseする" do
      @abst = AbstractSpliter.new("a1a2a3.1XYA ")
      @abst.filter_alphabet
      @abst.filterd_abst.should == "a a a xya"
    end

    it "2つ以上の空白は一つにする" do
      @abst = AbstractSpliter.new("a           b               c1           ")
      @abst.filter_alphabet
      @abst.filterd_abst.should == "a b c"
    end

    it "日本語も削る" do
      @abst = AbstractSpliter.new("眠いけどTwitter見てたらshinu")
      @abst.filter_alphabet
      @abst.filterd_abst.should == "twitter shinu"
    end
  end

#   describe "set_abst_md5" do 
#     it "文字列をmd5ハッシュに変換する" do
#       @abst = AbstractSpliter.new("apple")
#       @abst.set_abst_md5
#       @abst.abst_md5.should == "1f3870be274f6c49b3e31a0c6728957f"
#     end
#   end

  describe "set_bag_of_words" do
    it "1st case" do
      @abst = AbstractSpliter.new("abcde fghijk lmnop qrstu vwxyz")
      @abst.filter_alphabet
      @abst.set_bag_of_words
      @abst.bag_of_words["abcde"].should == 1
      @abst.bag_of_words["fghijk"].should == 1
    end

    it "2nd case" do
      @abst = AbstractSpliter.new("abcde fghijk abcde fghijk abcde")
      @abst.filter_alphabet
      @abst.set_bag_of_words
      @abst.bag_of_words["abcde"].should == 3
      @abst.bag_of_words["fghijk"].should == 2
    end

    it "単語数が1未満であれば ShortAbstractError を投げる" do
      @abst = AbstractSpliter.new("")
      @abst.filter_alphabet
      lambda{@abst.set_bag_of_words}.should raise_error(ShortAbstractError)
    end

    it "単語が1つ三文字未満ならば削る" do
      @abst = AbstractSpliter.new("ab cd ef gh ij kl mn op qr st")
      @abst.filter_alphabet
      lambda{@abst.set_bag_of_words}.should raise_error(ShortAbstractError)
    end
  end
  
end

