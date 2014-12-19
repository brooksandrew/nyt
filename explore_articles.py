# -*- coding: utf-8 -*-
"""
Created on Thu Dec 18 14:43:10 2014

@author: abrooks
"""

import os
import pymongo
from __future__ import division
import nltk as nltk
import string
from __future__ import unicode_literals
import re

os.chdir('/Users/abrooks/Documents/github/nyt')

conn = pymongo.MongoClient(host='mongodb://user1:password@ds063240.mongolab.com:63240/nyt')
db = conn.nyt
    
query = {'$where': 'this.body.length>50'}
art = list(db.articles1.find(query).limit(100))
len(art)

art2 = art
for i in range(0, len(art2)):
    art2[i]['body'] = re.sub('\\\\u....', '', repr(art2[i]['body']))

