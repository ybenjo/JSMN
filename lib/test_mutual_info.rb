# -*- coding: utf-8 -*-
require 'tokyocabinet'
require 'tokyotyrant'
require './access_db.rb'
include TokyoTyrant
include AccessDB

bow = {1000 => 1, 2000 => 20, 3000 => 30}
js = [7519, 7520, 7522]

p AccessDB.set_related_word_ids(bow, js)
