# -*- coding: utf-8 -*-
"""
Created on Fri Dec 19 15:19:07 2014

@author: abrooks
"""

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

os.chdir('/Users/abrooks/Documents/github/nyt')

conn = pymongo.MongoClient(host='mongodb://user1:password@ds063240.mongolab.com:63240/nyt')
db = conn.nyt
    
query = {'$where': 'this.body.length>50'}
art = list(db.articles1.find(query).limit(5))
len(art)

## attempt 1
t = art[0]['body']
t2 = t.encode('utf8')
t3 = nltk.word_tokenize(t)
t3
text = nltk.Text(t3)

t4 = nltk.PunktWordTokenizer(t)

## removing unicode chaacters 
import re
art2 = art
for i in range(len(art)):
    
    
import re
re.match('?', t)
re.sub('the', 'THE', t)

re.findall('\\\u2[0-9][0-9][0-9][0-9]', t)

re.sub('[0-9][0-9][0-9][0-9]', 'thing/u2019 this ia  s444444', )

re.findall('\\\\u....', repr(t))
re.findall(re.compile('\\\u....',re.UNICODE), t)
re.findall('2....', t)

import regex
a=regex.findall(u'.', t)

aa=nltk.tokenize.TreebankWordTokenizer().tokenize(t)

## attempt 2  this works... but need a dictionary of all characters
t = art[0]['body']
table = {0x201c: u'"', 0x201d: u'"', 0x2019: u"'"}
t.translate(table)

import html
html.unescape


b = open('/Users/abrooks/Desktop/test.txt', 'r').read()

import binascii
binascii.hexlify(t)

import unicodedata as ud
ud.normalize('NFC', t)

import re
re.compile('(?u)pattern')
pattern = re.compile("pattern", re.UNICODE)
re.()