# -*- coding: utf-8 -*-
"""
Created on Tue Dec 16 15:52:44 2014

@author: abrooks
"""

import os
import pymongo
from __future__ import division

os.chdir('/Users/abrooks/Documents/github/nyt')

conn = pymongo.MongoClient(host='mongodb://user1:password@ds063240.mongolab.com:63240/nyt')
db = conn.nyt

## these are the collections
cols = db.collection_names()
for i in cols:
    print i
    
## querying collection
db.articles1.find()
art = list(db.articles1.find())

hasb = 0
for i  in art: 
    if(len(i['body'])>50): hasb+=1

print(str(hasb/len(art)*100) + '% of articles have a body')