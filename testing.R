########################################################
## EXAMPLE PUTTING IT ALL TOGETHER
########################################################

library('httr')
library('XML')

## make urls to get meta data
url <- makeURL(begin_date='20140102', end_date='20140105', key='sample-key') #, key='sample-key'

## collect meta data
a <- getMeta(url, pages=15)

## collect articles
artxt <- getArticles(a, n=20, overwrite=F)
artxt <- getArticles(artxt, n=20, overwrite=F, sleep=0)
artxt <- getArticles(artxt, n=15, overwrite=F, sleep=0)

##############
### MONGO ####
##############
library('RMongo')
library('rjson')
mg1 <- mongoDbConnect('nyt')
dbShowCollections(mg1)
query <- dbGetQuery(mg1, 'testData', "{x:3}")

## insert document
a[[2]]$body <- bb[[2]]
doc <- a[[2]]
output <- dbInsertDocument(mg1, "nyt", toJSON(doc))

query <- dbGetQuery(mg1, 'nyt', "{wordcount:128}")

