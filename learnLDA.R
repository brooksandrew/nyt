library('gtools')
library('RMongo')


## Get corpus in
mg1 <- mongoDbConnect('nyt', host='ds063240.mongolab.com:63240') 
authenticated <- dbAuthenticate(mg1, username='user1', password='password')
query <- dbGetQuery(mg1, collection='articles1', query="{'$where': 'this.body.length>100'}", skip=0, limit=100)
data <- query[query$abstract!='',]



## PARAMETERS
D <- 1000 # number of documents
K <- 15 # number of topics
W <- 50000 # number of unique words

## defining random variables: 
alpha <- rep(1, K) # uniform Dirichlet prior
theta <- function() rdirichlet(n=1, alpha=alpha) # Dirichlet random variable
beta <- # K by W matrix
  
## Initialize Priors
dp <- rdirichlet(n=D, alpha=rep(1, K)) # Dirichlet priors for each document


wp <- rmultinom(1, size=1, prob=rdirichlet(n=1, alpha=rep(1, K))) # Multinomial priors for each word

                
                
x1 <- rdirichlet(n=10000, alpha=rep(1, 10))
x2 <- rmultinom(n=10000, size=2, prob=rep(1, 10)/10)
                 
