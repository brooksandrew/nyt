## Generate a corpus
rawdocs <- c('i like to eat turkey and turtles yay turkey',
          'i like to eat cake on a holiday say i',
          'snail on a turtle race',
          'turtle says hi to turkey',
          'snail like to run fast',
          'i like to run faster than a turtle run')
docs <- strsplit(rawdocs, split="[[:blank:][:punct:]]", perl=T)

## PARAMETERS
K <- 2 # number of topics
alpha <- .001 # hyperparemeter
eta <- .001 # hyperparameter
iterations <- 10000 # iterations for collapsed gibbs sampling

## Assign WordIDs
vocab <- unique(unlist(docs))
for(i in 1:length(docs)) docs[[i]] <- match(docs[[i]], vocab)

## 1. Randomly assign topics to words in each doc.  2. Generate word-topic count matrix.
wt <- matrix(0, K, length(vocab))
ta <- docs
for(d in 1:length(docs)){
  for(w in 1:length(docs[[d]])){
    ta[[d]][w] <- sample(1:K, 1) # which(rmultinom(1,1,rep(1,K))==1)
    ti <- ta[[d]][w]
    wi <- docs[[d]][w]
    wt[ti,wi] <- wt[ti,wi]+1     
  }
}

## Generate doucment-topic count matrix
dt <- matrix(0, length(docs), K)
for(d in 1:length(docs)){
  for(t in 1:K){
    dt[d,t] <- sum(ta[[d]]==t)   
  }
}

## Update word topic assignments
v<-0
for(i in 1:iterations){
  for(d in 1:length(docs)){
    for(w in 1:length(docs[[d]])){
      
      t0 <- ta[[d]][w]
      wid <- docs[[d]][w]
      
      dt[d,t0] <- dt[d,t0]-1
      wt[t0,wid] <- wt[t0,wid]-1 
      
      ## UPDATE TOPIC ASSIGNMENT FOR EACH WORD -- COLLAPSED GIBBS SAMPING MAGIC.  POSTERIOR MAGIC. see page 8. http://psiexp.ss.uci.edu/research/papers/SteyversGriffithsLSABookFormatted.pdf
      denom_a <- sum(dt[d,]) + K * alpha # number of tokens in document + number topics * alpha
      denom_b <- rowSums(wt) + length(vocab) * eta # number of tokens in each topic + # of words in vocab * eta
      p_z <- (wt[,wid] + eta) / denom_b * (dt[d,] + alpha) / denom_a # calculating probability word belongs to each topic
      t1 <- sample(1:K, 1, prob=p_z/sum(p_z)) # draw topic for word n from multinomial using probabilities calculated above
      
      ta[[d]][w] <- t1
      dt[d,t1] <- dt[d,t1]+1
      wt[t1,wid] <- wt[t1,wid]+1 
    
      #if(t0!=t1) print(paste0('doc:', d, ' token:' ,w, ' topic:',t0,'=>',t1))
      if(t0!=t1) v[length(v)+1] <- i
    }
  }
}

## Pulling out topic and word probabilities

phi <- (wt + eta) / (rowSums(wt+eta)) #+ length(vocab)*eta
theta <- (dt+alpha) / rowSums(dt+alpha) #+ K*alpha
colnames(phi) <- words




