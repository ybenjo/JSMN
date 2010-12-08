# -*- coding: utf-8 -*-
require "../lib/access_db.rb"

describe AccessDB do
  before do
    include AccessDB
  end
  
  describe ".active?" do
    it "はdbが起動している場合はtrueを返す" do
      AccessDB.stub!(:word_db_active?).and_return(true)
      AccessDB.stub!(:journal_db_active?).and_return(true)
      AccessDB.active?.should be_true
    end
    
    it "は単語dbが起動していない場合 WordDatabaseDownError を投げる" do
      AccessDB.stub!(:word_db_active?).and_return(false)
      AccessDB.stub!(:journal_db_active?).and_return(true)
      lambda{AccessDB.active?}.should raise_error(WordDatabaseDownError)
    end

    it "はジャーナルdbが起動していない場合 JournalDatabaseDownError を投げる" do
      AccessDB.stub!(:word_db_active?).and_return(true)
      AccessDB.stub!(:journal_db_active?).and_return(false)
      lambda{AccessDB.active?}.should raise_error(JournalDatabaseDownError)
    end
  end

  describe "convert_bag_of_words_to_id" do
    before do
      AccessDB.should_receive(:get_word_id).any_number_of_times.with("rat").and_return(1)
      AccessDB.should_receive(:get_word_id).any_number_of_times.with("mouse").and_return(2)
      AccessDB.should_receive(:get_word_id).any_number_of_times.with("mickey").and_return(nil)
    end
    
    it "はhashのbag_of_wordsを受け取ってidに変換する" do
      AccessDB.convert_bag_of_words_to_id({"rat" => 1, "mouse" => 2}).should == {1 => 1, 2 => 2}
    end

    it "はdbに存在しない文字列については返さない" do
      AccessDB.convert_bag_of_words_to_id({"rat" => 1, "mouse" => 2, "mickey" => 3}).should == {1 => 1, 2 => 2}
    end
  end
  
end
