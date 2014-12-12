library('httr')
library('XML')

## url generated from NYT API documentation

setwd('/Users/abrooks/Documents/github/nyt')
artkey <- scan('key.txt', what='character')

url <- paste0('http://api.nytimes.com/svc/search/v2/articlesearch.json?callback=svc_search_v2_articlesearch&
              begin_date=20120101&end_date=20130101&api-key=','sample-key')

url <- paste0('http://api.nytimes.com/svc/search/v2/articlesearch.json?',
              'q=data+science', 
              '&begin_date=20110101&end_date=20120101', 
              '&api-key=', artkey,
              '&page=25')

pagetxt <- GET(url)
page <- content(pagetxt, 'parsed')

art <- sapply(page$response$docs, function(x) c(x['word_count'], 
                                                x['snippet'], 
                                                x['pub_date'],
                                                x['web_url']))









View(t(art))


pl <- list()
for(w in art['web_url',]) {
  print(w)
  p <- GET(w)
  pl[[length(pl)+1]] <- content(p, 'parsed')
}