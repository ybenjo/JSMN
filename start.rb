# -*- coding: utf-8 -*-
require "rubygems"
require "sinatra"
require "haml"
require "sass"
require "open-uri"
require "yaml"
require "./lib/abstract_spliter.rb"
require "./lib/access_db.rb"


helpers do
  include Rack::Utils; alias_method :h, :escape_html
end

get '/stylesheet.sass' do
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
    @abst.filter_alphabet
    @abst.set_bag_of_words
    @abst.write_bag_of_words

    raise NoSimHashError if !File.exist?("#{@config["simhash_path"]}/simhash")
    
    system "#{@config["simhash_path"]}/simhash --q /tmp/jsmn_#{@abst.abst_md5} \\
    --fserver localhost:#{@config["fserver_port"]} \\
    --hserver localhost:#{@config["hserver_port"]} \\
    --fast --normal --limit #{@config["l"]} -k #{@config["k"]} >> #{@config["output_log"]}"

    raise UnexpectedError if !File.exist?("/tmp/jsmn_#{@abst.abst_md5}.out")
    
    @similarity = []
    @content_title = Hash.new{ }
    open("/tmp/jsmn_#{@abst.abst_md5}.out"){|f|
      f.each{|l|
        id, score = l.chomp.split(",")
        @similarity.push [id.to_s, score.to_f]
        @content_title[id] = AccessDB.get_journal_string(id)
      }
    }

    #特徴語出力用
    @journals = [ ]
    @similarity.each do |e|
      @journals.push e[0].to_i
    end

    @top_words = AccessDB.set_top3_mutual_info(@abst.bag_of_words, @journals)
#     @top_words.each_key do |key|
#       @top_words[key] = AccessDB.get_word_ids_string(@top_words[key])
#     end
    
    @abst.delete_bag_of_words
    
    haml :result
  rescue => @error_message
    @abst.delete_bag_of_words
    haml :error
  end
end

not_found do
  redirect '/JSMN'
end
