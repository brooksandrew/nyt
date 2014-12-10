########################################################
## this function generates the URL for a GET request to the New York Times Article Search API
########################################################
getArtURL <- function(q=NULL, fq=NULL, begin_date=NULL, end_date=NULL, key=getOption("nyt_as_key"), page=0){
  arglist <- list(q=q, fq=fq, begin_date=begin_date, end_date=end_date, 'api-key'=key, page=page)
  
  url <- 'http://api.nytimes.com/svc/search/v2/articlesearch.json?'
  for(i in 1:length(arglist)){
    if(is.null(unlist(arglist[i]))==F){
      url <- paste0(url, '&', names(arglist[i]), '=', arglist[i])
    }
  }
  return(url)
}

## examples
if(1==0){
  library('httr')
  url <- getArt(q='andrew+brooks', begin_date='20110101', end_date='20131025', key='sample-key')
}


########################################################
## this function actually makes the GET requests to the NYT Article Search API
########################################################

nyt_as_get_meta <- function(url, pages=Inf) {
  art <- list()
  i <- 1
  while(i<pages){
    print(i)
    urlp <- gsub('page=\\d+', paste0('page=', i), url)
    p <- GET(urlp)
    pt <- content(p, 'parsed')
    if(length(pt$response$docs)>0) art <- append(art, pt$response$docs)
    else {print(paste0(i, ' pages collected')); break}
    i <- i+1
  }
  return(art)
}

## example
if(1==0){
  url <- getArtURL(q='andrew+brooks', begin_date='20110101', end_date='20111025', key='sample-key')
  a <- nyt_as_get_meta(url, pages=100)
}

########################################################
## this function extracts the text for a list of URLs
########################################################

nyt_as_get_art <- function(art_urls, n=Inf) {
  artxt <- list()
  for(i in 1:(min(length(art_urls), n))){
    try({
      print(i)
      p <- GET(art_urls[i])
      pt <- content(p, 'text')
      artxt <- append(artxt, pt)
    })
  }
  return(artxt)
}


## example
if(1==0){
  url <- getArtURL(q='andrew+brooks', begin_date='20110101', end_date='20111025', key='sample-key')
  a <- nyt_as_get_meta(url, pages=5)
  urls <- unlist(sapply(a, function(x) x['web_url']))
  artxt <- nyt_as_get_art(urls, n=12)
}

########################################################
## This fucnction strips out just the text of an article
########################################################

get_body <- function(arts) {
  artbody <- list()
  xpath2try <- c('//div[@class="articleBody"]//p',
                 '//p[@class="story-body-text story-content"]',
                 '//p[@class="story-body-text"]'
  )
  for(i in 1:length(arts)) {
    print(i)
    for(xp in xpath2try) {
      bodyi <- paste(xpathSApply(htmlParse(arts[[i]]), xp, xmlValue), collapse='')
      if(nchar(bodyi)>0) break
    }
    artbody <- append(artbody, list(bodyi))
  }  
  return(artbody)
}

## examplex
if(1==0) {
  bb <- get_body(artxt)
}

########################################################
## EXAMPLE PUTTING IT ALL TOGETHER
########################################################

library('httr')
library('XML')

## make urls to get meta data
url <- getArtURL(begin_date='20140102', end_date='20140105', key='sample-key') #, key='sample-key'

## collect meta data
a <- nyt_as_get_meta(url, pages=150)

## collect articles
urls <- unlist(sapply(a, function(x) x['web_url']))
artxt <- nyt_as_get_art(urls, n=100)

## parse out just the article body
bb <- get_body(artxt)

##### TESTING ######
sapply(bb, nchar)
urls[which(sapply(bb, nchar)==0)]


bodyi <- paste(xpathSApply(htmlParse(artxt[[21]]), '//p[@class="story-body-text story-content"]//p', xmlValue), collapse='')
bodyi


story-body-text story-content

