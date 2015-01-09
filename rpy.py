# -*- coding: utf-8 -*-
"""
Created on Tue Jan  6 12:10:43 2015

@author: abrooks
"""


#import string
#import re
#import numpy as np
#import operator
#import pandas as pd
#from ggplot import *
#import datetime
import pickle
import os
os.chdir('/Users/abrooks/Documents/github/nyt')
#from helpers import *
#import random
#from sklearn import tree
#import nltk as nltk

## retrieving results
art_file = open('articles_31234.p', 'rb')
artFull = pickle.load(art_file)

