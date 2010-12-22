*説明
JSMN用にデータをパースします。

*必要なもの
そもそもこれが実行されるのはg86であるという前提で進めます。
- 最新のpubmedのダンプデータ(xml)が入ったフォルダ
- tokyotyrant serverの起動
-- 起動用のスクリプトは /Users/y_benjo/JSMN/data/daemons にあるので全て　./#{ファイル名} start してください

*ツール
- gcc 4.2.1
- Ruby 1.8.7
-- 1.9x系列での動作は未確認です
- RubyGems
-- nokogiri
-- tokyocabinet
-- tokyotyrant(rubyバインディング)


*注意
- /tmp以下に300MB程度の作業用空き領域を必要とします。

*処理の流れ
parse_xml.rb -(pipe)-> filter_symbol_and_num.rb -(pipe)-> make_bow_and_ids ---> temporary file --> setter.rb --> tokyotyrant
            |                                                              |
            |                                                              |--> temporary file --> tinysimhash --> tokyotyrant
            |                                                              |
            |                                                              ---> temporary file --> mutual_information --> tokyotyrant
            |
            |-----------------------------------------------------------------> temporary file --> impact_factor.rb --> tokyotyrant
