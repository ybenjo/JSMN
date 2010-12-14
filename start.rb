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
    system "#{@config["simhash_path"]}/simhash --q /tmp/jsmn_#{@abst.abst_md5} \\
    --fserver localhost:#{@config["fserver_port"]} \\
    --hserver localhost:#{@config["hserver_port"]} \\
    --fast --normal --limit #{@config["l"]} -k #{@config["k"]} >> #{@config["output_log"]}"

    @similarity = []
    @content_title = Hash.new{ }
    open("/tmp/jsmn_#{@abst.abst_md5}.out"){|f|
      f.each{|l|
        id, score = l.chomp.split(",")
        @similarity.push [id.to_s, score.to_f]
        # @paper_title[id.to_s] = open("http://togows.dbcls.jp/entry/pubmed/#{id.to_s}/ti").read
        @content_title[id] = AccessDB.get_journal_string(id)
      }
    }
    @abst.delete_bag_of_words
    
    haml :result
  rescue => @error_message
    # @abst.delete_bag_of_words
    haml :error
  end
end

not_found do
  redirect '/JSMN'
end
