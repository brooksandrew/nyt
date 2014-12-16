
setwd('/Users/abrooks/Documents/github/nyt')
source('getArtURL.R')

## ########################
## PARAMETERS
## ########################
days <- gsub('-', '', seq(as.Date('2013-01-01'), Sys.Date()-1, by=1))
mongoCreds <- list(dbName='nyt', collection='articles1', host='ds063240.mongolab.com:63240', username='user1', password='password')
key <- 'sample-key' #scan('key.txt', what='character')


## #################################
## Letting it rip ... do not touch
## #################################
all <- list()
system.time({
  for(d in days) {
    url <- makeURL(begin_date=d, end_date=d, key=key)
    meta <- getMeta(url, pages=Inf, sleep=0.1)
    artxt <- getArticles(meta, n=Inf, sleep=0.1, overwrite=T, mongo=mongoCreds)
    print(paste0(d, ' complete at ', Sys.time()))
    all <- append(all, artxt)
  }
})


## #################################
## DIAGNOSTICS ...  run interactively
## #################################

hist(table(as.Date(sapply(all, function(x) x[['pub_date']]))), breaks=20)
 
hl <- data.frame(sort(unlist(sapply(all, function(x) x[['headline']]['print_headline']))))
data.frame(hl)

sn <- data.frame(sort(unlist(sapply(all, function(x) x[['section_name']]))))
barplot(sort(table(sn), decreasing=T), las=2)

sort(table(unlist(sapply(all, function(x) x['document_type']))), decreasing=T)

bc <- unlist(sapply(all, function(x) nchar(x[['body']])>0))
d <- as.Date(unlist(sapply(all, function(x) x[['pub_date']])))
d <- unlist(sapply(all, function(x) x[['type_of_material']]))
d2 <- unlist(sapply(all, function(x) x[['source']]))
d1 <- unlist(sapply(all, function(x) x[['document_type']]))

table(d, bc)
for(i in 1:length(all)) print(paste0(i,'  ',nchar(all[[i]]$body), '   ', as.Date(all[[i]]$pub_date),'   ', all[[i]]$web_url))

lp <- sapply(all, function(x) x[['body']])
library('wordcloud')
library('tm')
corpus <- Corpus(VectorSource(lp), readerControl=list(language="eng", reader=readPlain))
lpmap <- tm_map(corpus, content_transformer(tolower))
lpmap <- tm_map(lpmap,  removeWords, stopwords('english'))
wordcloud(lpmap, random.order=F, colors=brewer.pal(6,"Dark2"))



