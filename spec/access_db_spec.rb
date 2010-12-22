# -*- coding: utf-8 -*-
require "../lib/access_db.rb"

describe AccessDB do
  before do
    @db = AccessDB.new("../config.yaml")
    @db.stub!(:word_id_db_active?).and_return(true)
    @db.stub!(:journal_db_active?).and_return(true)
    @db.stub!(:id_word_db_active?).and_return(true)
    @db.stub!(:mutual_info_db_active?).and_return(true)
    @db.stub!(:impact_factor_db_active?).and_return(true)
  end
  
  describe ".active?" do
    it "はdbが起動している場合はtrueを返す" do
      @db.active?.should be_true
    end
    
    it "は単語iddbが起動していない場合 WordDatabaseDownError を投げる" do
      @db.stub!(:word_id_db_active?).and_return(false)
      lambda{@db.active?}.should raise_error(WordIDDatabaseDownError)
    end

    it "はジャーナルdbが起動していない場合 JournalDatabaseDownError を投げる" do
      @db.stub!(:journal_db_active?).and_return(false)
      lambda{@db.active?}.should raise_error(JournalDatabaseDownError)
    end
    
    it "はid単語dbが起動していない場合 IDWordDatabaseDownError を投げる" do
      @db.stub!(:id_word_db_active?).and_return(false)
      lambda{@db.active?}.should raise_error(IDWordDatabaseDownError)
    end

    it "は総合情報量dbが起動していない場合 MutualInfomationDatabaseDownError を投げる" do
      @db.stub!(:mutual_info_db_active?).and_return(false)
      lambda{@db.active?}.should raise_error(MutualInformationDatabaseDownError)
    end

    it "はインパクトファクターdbが起動していない場合 ImpactFactorDatabaseDownError を投げる" do
      @db.stub!(:impact_factor_db_active?).and_return(false)
      lambda{@db.active?}.should raise_error(ImpactFactorDatabaseDownError)
    end

  end
end
