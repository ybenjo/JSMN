# -*- coding: utf-8 -*-
require "rubygems"
require "sinatra"
require "haml"
require "sass"
require "open-uri"
require "yaml"
require "./lib/abstract_spliter.rb"
require "./lib/access_db.rb"
require "./lib/supervision.rb"

helpers do
  include Rack::Utils; alias_method :h, :escape_html
end

get 'stylesheet.sass' do
  content_type 'text/css', :charset => 'utf-8'
  sass :stylesheet
end

get '/?' do
  haml :index
end

post '/result' do
  begin
    @config = YAML.load_file("./config.yaml")
    @abst = AbstractSpliter.new(params[:abstract])

    working(@abst.abst[0...100])
    
    @abst.filter_alphabet
    @abst.set_bag_of_words
    @abst.write_bag_of_words

    working(@abst.bag_of_words)

    raise NoSimHashError if !File.exist?("#{@config["simhash_path"]}/simhash")
    
    system "#{@config["simhash_path"]}/simhash --q /tmp/jsmn_#{@abst.abst_md5} \\
    --fserver localhost:#{@config["fserver_port"]} \\
    --hserver localhost:#{@config["hserver_port"]} \\
    --fast --normal --limit #{@config["l"]} -k #{@config["k"]}"

    raise UnexpectedError if !File.exist?("/tmp/jsmn_#{@abst.abst_md5}.out")
    
    @titles = []
    @similarity = []
    @content_title = Hash.new{ }
    open("/tmp/jsmn_#{@abst.abst_md5}.out"){|f|
      f.each{|l|
        id, score = l.chomp.split(",")
        @similarity.push [id.to_s, score.to_f]
        title = AccessDB.get_journal_string(id)
        @content_title[id] = title
        @titles.push title
      }
    }


    #インパクトファクター所得
    @ifs = AccessDB.get_journal_impact_factor(@titles)

    #特徴語出力用
    @journals = [ ]
    @similarity.each do |e|
      @journals.push e[0].to_i
    end

    @intersections, @top_words = AccessDB.set_related_word_ids(@abst.bag_of_words, @journals, @config["related_size"])
    @top_words.each_key do |key|
      @top_words[key] = AccessDB.get_word_ids_string(@top_words[key])
    end

    @intersections = AccessDB.get_word_ids_string(@intersections)
    
    @abst.delete_bag_of_words
    
    haml :result
  rescue => @error_message
    notice(@abst.abst)
    notice(@error_message.inspect)
    @abst.delete_bag_of_words
    haml :error
  end
end

not_found do
  redirect '/JSMN'
end
