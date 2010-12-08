require "rubygems"
require "sinatra"
require "haml"
require "sass"
require "open-uri"
require "yaml"
require "./lib/abstract_spliter.rb"

helpers do
  include Rack::Utils; alias_method :h, :escape_html
end

get '/stylesheet.sass' do
  content_type 'text/css', :charset => 'utf-8'
  sass :stylesheet
end

get '/?' do
  haml :index
  @config = YAML.load_file("./config.yaml")
end

post '/result' do
  begin
    @abst = AbstractSpliter.new(params[:abstract])
    @abst.filter_alphabet
    @abst.set_bag_of_words
    @abst.write_bag_of_words
    system "#{@config[simhash_path]}/simhash --q /tmp/jsmn_#{@abst.abst_md5} \\
    --fserver localhost:#{@config[fserver_port]} \\
    --hserver localhost:#{@config[hserver_port]} \\
    --fast -l #{@config[l]} -k #{@config[k]} >> #{@config[output_log]}"

    @similarity = []
    @paper_title = Hash.new{ }
    open("/tmp/jsmn_#{@abst.abst_md5}.out"){|f|
      f.each{|l|
        id, score = l.chomp.split(",")
        @similarity.push [id.to_s, score.to_f]
        @paper_title[id.to_s] = open("http://togows.dbcls.jp/entry/pubmed/#{id.to_s}/ti").read
      }
    }
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
