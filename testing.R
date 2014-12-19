########################################################
## EXAMPLE PUTTING IT ALL TOGETHER
########################################################

library('httr')
library('XML')
setwd('/Users/abrooks/Documents/github/nyt')
key <- scan('key.txt', what='character')

## make urls to get meta data
url <- makeURL(begin_date='20140502', end_date='20140502', key='sample-key') #, key='sample-key'

## collect meta data
a <- getMeta(url, pages=, tryn=3, sleep=0)

## collect articles
mongoCreds <- list(dbName='nyt', collection='test2', host='ds063240.mongolab.com:63240', username='user1', password='password')
artxt <- getArticles(a, n=20, overwrite=F, mongo=mongoCreds)
artxt <- getArticles(artxt, n=20, overwrite=F, sleep=0)
artxt <- getArticles(artxt, n=15, overwrite=F, sleep=0)

##############
### MONGO ####
##############
library('RMongo')
library('rjson')


## mg1 <- mongoDbConnect('nyt') ## local
mg1 <- mongoDbConnect('nyt', 'ds063240.mongolab.com:63240') ## remote
authenticated <-dbAuthenticate(mg1, username='user1', password='password')

dbShowCollections(mg1)
query <- dbGetQuery(mg1, 'testData', "{x:3}")

## insert document
a[[2]]$body <- bb[[2]]
doc <- a[[2]]
output <- dbInsertDocument(mg1, "nyt", doc)

query <- dbGetQuery(mg1, 'nyt', "{x:23}")


## QUERYING #############################

library('RMongo')
mongo <- list(dbName='nyt', collection='articles1', host='ds063240.mongolab.com:63240', username='user1', password='password')
con <- mongoDbConnect(mongo$dbName, mongo$host)
authenticated <-dbAuthenticate(con, username=mongo$username, password=mongo$password)

output <- dbGetQuery(con, 'articles1', '{"source":"The New York Times"}', 0, 500)

dim(output)
sort(table(nchar(output$body)>50))

sort(table(output$document_type[which(output$X_id!='' | is.na(output$X_id))]))







