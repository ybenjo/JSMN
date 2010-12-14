# -*- coding: utf-8 -*-
require '../lib/abstract_spliter.rb'

describe AbstractSpliter do
  describe "filter_alphabet" do
    it "カッコをスペースに置換しスペースで区切って文末の空白も消してdowncaseする" do
      @abst = AbstractSpliter.new("(123aasbc) ")
      @abst.filter_alphabet
      @abst.filterd_abst.should == "123aasbc"
    end

    it "2つ以上の空白は一つにする" do
      @abst = AbstractSpliter.new("a           b               c1           ")
      @abst.filter_alphabet
      @abst.filterd_abst.should == "a b c1"
    end

    it "日本語も削る" do
      @abst = AbstractSpliter.new("眠いけどTwitter見てたらshinu")
      @abst.filter_alphabet
      @abst.filterd_abst.should == "twitter shinu"
    end
  end

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

