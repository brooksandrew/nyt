########################################################
## this function generates the URL for a GET request to the New York Times Article Search API
########################################################
makeURL <- function(q=NULL, fq=NULL, begin_date=NULL, end_date=NULL, key=getOption("nyt_as_key"), page=0){
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
  url <- makeURL(q='andrew+brooks', begin_date='20110101', end_date='20131025', key='sample-key')
}


########################################################
## this function actually makes the GET requests to the NYT Article Search API
########################################################

getMeta <- function(url, pages=Inf, sleep=0.1) {
  art <- list()
  i <- 1
  e <- c(-3,-2,-1) 
  while(i<pages){
    if(length(unique(e[(length(e)-2):length(e)]))==1) i <- i+1 
    tryget <- try({
      urlp <- gsub('page=\\d+', paste0('page=', i), url)
      p <- GET(urlp)
      pt <- content(p, 'parsed')
      if(length(pt$response$docs)>0) art <- append(art, pt$response$docs)
      else {print(paste0(i, ' pages collected')); break}
      print(i)
      i <- i+1
    })
    
    if(class(tryget)=='try-error') {
      print(paste0(i, ' error - not scraped'))
      e <- c(e, i)
      e <- e[(length(e)-2):length(e)]
      Sys.sleep(0.5) ## probably scraping too fast -- slowing down
    }
    Sys.sleep(sleep)
  }
  return(art)
}

## example
if(1==0){
  library('httr')
  url <- makeURL(q='andrew', begin_date='20110101', end_date='20111025', key='sample-key')
  a <- getMeta(url, pages=111, sleep=0)
}

########################################################
## this function extracts the text for a list of URLs
########################################################

getArticles <- function(meta, n=Inf, overwrite=F, sleep=0.1) {
  metaArt <- meta
  if(overwrite==T) {artIndex <- 1:n
  } else { 
    ii <-  which(sapply(meta, function(x) is.null(x[['bodyHTML']])))
    artIndex <- ii[1:min(n,length(ii))]
  }
  for(i in artIndex){ 
    tryget <- try({
      if(overwrite==T | (is.null(meta[[i]]$body)==T & overwrite==F)) {
        p <- GET(meta[[i]]$web_url)
        metaArt[[i]]$bodyHTML <- content(p, 'text')
        metaArt[[i]]$body <- parseArticleBody(metaArt[[i]]$bodyHTML)
        print(i)
      }
    })
    if(class(tryget)=='try-error') {
      print(paste0(i, ' error - not scraped'))
      e <- c(e, i)
      e <- e[(length(e)-2):length(e)]
      Sys.sleep(0.5) ## probably scraping too fast -- slowing down
    }
    Sys.sleep(sleep)
  }
  return(metaArt)
}


## example
if(1==0){
  library('httr')
  library('XML')
  url <- makeURL(q='andrew+brooks', begin_date='20110101', end_date='20111025', key='sample-key')
  a <- getMeta(url, pages=25)
  artxt <- getArticles(a, n=12, overwrite=F)
  artxt <- getArticles(artxt, n=12, overwrite=F)
}

########################################################
## This fucnction strips out just the text of an article
########################################################

parseArticleBody <- function(artHTML) {
  xpath2try <- c('//div[@class="articleBody"]//p',
                 '//p[@class="story-body-text story-content"]',
                 '//p[@class="story-body-text"]'
                 )
  for(xp in xpath2try) {
    bodyi <- paste(xpathSApply(htmlParse(artHTML), xp, xmlValue), collapse='')
    if(nchar(bodyi)>0) break
  }
  return(bodyi)
}

## example
if(1==0) {
  bb <- parseArticleBody(artxt)
  write.csv(bb[[1]], file='art1.csv')
}

