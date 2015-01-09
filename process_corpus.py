# -*- coding: utf-8 -*-
"""
Created on Thu Dec 18 14:43:10 2014

@author: abrooks
"""

import os
import pymongo
import nltk as nltk
import string
import re
import numpy as np

os.chdir('/Users/abrooks/Documents/github/nyt')
from helpers import *

conn = pymongo.MongoClient(host='mongodb://user1:password@ds063240.mongolab.com:63240/nyt')
db = conn.nyt
    
query = {'$where': 'this.body.length>50'}
art = list(db.articles1.find(query)) # limit(5000)

## PARSE UNICODE DATA to clean strings for each article
for i in range(0, len(art)):
    art[i]['bodyraw'] = art[i]['body']
    art[i]['body'] = str(repr(art[i]['body']))
    art[i]['body'] = re.sub('\\\\u....', '', art[i]['body'])
    art[i]['body'] = re.sub('\\\\x..', '', art[i]['body'])
    art[i]['body'] = art[i]['body'].replace('\\n', '')
    art[i]['body'] = art[i]['body'][2:(len(art[i]['body'])-1)] # cleaning up punctuation at end and beginning
    art[i]['body'] = str(art[i]['body'])
    if i % 1000==0: print i, 'documents cleaned' 

## TOKENIZATION & PUNCTUATION REMOVAL ... the loops over tokens are slow...
punc_re = re.compile('[%s]' % re.escape(string.punctuation))
for i in range(0, len(art)):
    art[i]['body_np'] = punc_re.sub(' ', art[i]['body'])
    art[i]['body_np'] = art[i]['body_np'].lower()
    art[i]['tokens'] = nltk.word_tokenize(art[i]['body_np'])  
    art[i]['tokens_nsw'] = removeStopWords(art[i]['tokens'])
    art[i]['tokens_nsw'] = removeTokensWithNumbers(art[i]['tokens_nsw'])
    art[i]['tokens_nsw'] = stemMorphy(art[i]['tokens_nsw'])
    art[i]['text'] = nltk.Text(art[i]['tokens_nsw'])
    if i % 1000==0: print i, 'documents pre-processed'  


## saving results
import cPickle as pickle
art_file = open('articles_31234.p', 'wb')
pickle.dump(art, art_file)
art_file.close()
