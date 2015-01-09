
# Latent Dirichlet Allocation + collapsed Gibbs sampling
# This code is available under the MIT License.
# (c)2010-2011 Nakatani Shuyo / Cybozu Labs Inc.
setwd('/Users/abrooks/Box Sync/Andrew Brooks/lda/shuyo_python/iir')

K <- 2 # topics
I <- 1 # ?

## Generate corpus
text <-  c('i like to eat turkey and turtles yay turkey',
           'i like to eat cake on a holiday say i',
           'snail on a turtle race',
           'turtle says hi to turkey',
           'snail like to run fast',
           'i like to run faster than a turtle run')

corpus <- strsplit(text, split="[[:blank:][:punct:]]", perl=T);

######################################
## Generate vocabulary and word IDs ##
######################################
words <- c()
words_id <- list()
docs <- list()
M <- 0 # number of documents
for(line in corpus) {
	doc <- c();
	for (term in line) {
		if (term == "") next;
		if (is.null(words_id[[term]])) {
			words <- append(words, term);
			words_id[[term]] <- length(words);
		}
		doc <- append(doc, words_id[[term]]);
	}
	if (length(doc)==0) next;
	M <- M + 1;
	docs[[M]] <- doc;
}
V <- length(words) 


z_m_n <- list();  # list of topic assignments for each word in each doc. randomly generated.
n_m_z <- matrix(numeric(M*K),M) # count matrix: document by topic matrix.  initialize.
n_z_t <- matrix(numeric(K*V),K) # count matrix: topic by word matrix. intitialize.
n_z <- numeric(K) # tokens per topic

for(m in 1:M) {
	doc <- docs[[m]];
	N_m <- length(doc);

	z_n <- sample(1:K, N_m, replace=T) # pick random topics for each word in each doc
	z_m_n[[m]] <- z_n # save these topic assignments per word
	for(n in 1:N_m) { ## for each n word in the doc
		z <- z_n[n] # topic for the nth word
		t <- doc[n] # wordID for nth word
		n_m_z[m,z] <- n_m_z[m,z] + 1
		n_z_t[z,t] <- n_z_t[z,t] + 1
		n_z[z] <- n_z[z] + 1
	}
}

alpha <- 0.001;
beta <- 0.001;

for(ita in 1:I) {
	#print("-------------------------------------------------------------------");
	#print(paste0('ita ', ita))
	
	changes <- 0
	for(m in 1:M) { # for each document
		doc <- docs[[m]] # wordIDs for tokens in document
		N_m <- length(doc) # number of tokens in document
		for(n in 1:N_m) { #for each word n in each document
			t <- doc[n] # wordID for token n in document 
			z <- z_m_n[[m]][n]; # z_i.  assigned topic for token n.

			# z_{-i}.  Subtracting from count matrices 
			n_m_z[m,z] <- n_m_z[m,z] - 1 # subtract 1 from count matrix of document vs topic for token n
			n_z_t[z,t] <- n_z_t[z,t] - 1 # subtract 1 from count matrix of topic vs wordID for token n
			n_z[z] <- n_z[z] - 1 # subtract 1 from count matrix of tokens per topic

			# p(z|z_{-i}) POSTERIOR MAGIC
			denom_a <- sum(n_m_z[m,]) + K * alpha # number of tokens in document + number topics * alpha
			denom_b <- rowSums(n_z_t) + V * beta # number of tokens in each topic + # of words in vocab * beta
			p_z <- (n_z_t[,t] + beta) / denom_b * (n_m_z[m,] + alpha) / denom_a # calculating probability word belongs to each topic
			z_i <- sample(1:K, 1, prob=p_z) # draw topic for word n from multinomial using probabilities calculated above

			z_m_n[[m]][n] <- z_i # Update the topic assignment for word n in document m 
			#cat(paste0(m, ',', n, ' ', z, ' => ', z_i, ' |  p_z=', paste(p_z, collapse=','))) # summary of what happened for that word
			if (z != z_i) changes <- changes + 1;
      
      # Updating count matrices based on new topic assignments per word.
			n_m_z[m,z_i] <- n_m_z[m,z_i] + 1
			n_z_t[z_i,t] <- n_z_t[z_i,t] + 1
			n_z[z_i] <- n_z[z_i] + 1
		}
	}
}

phi <- matrix(numeric(K*V), K) # document by topic matrix. initialize w zeros. Probabilities for topic assignment per document.
theta <- matrix(numeric(M*K), M) # topic by wordID matrix. initialize w zeros.  Probabilities for topic assignement per document.
for(m in 1:M) { # for each doc
	theta_m <- n_m_z[m,] + alpha # vector: count of tokens assigned to each topic + alpha
	theta[m,] <- theta_m / sum(theta_m) # percentage of words in document m assigned to each topic
}
for(z in 1:K) { # for each topic
	phi_z <- n_z_t[z,] + beta # count of tokens assigned to each topic
	phi[z,] <- phi_z / sum(phi_z) # relative frequency of each word for each topic
}
colnames(phi) <- words

##########################
## Printing out results ##
##########################

options(digits=5, scipen=1, width=100);
sink(format(Sys.time(), "lda%m%d%H%M.txt"));

for(m in 1:M) {
	doc <- docs[[m]];
	N_m <- length(doc);
	cat(sprintf("\n[corpus %d]-------------------------------------\n", m));
	print(theta[m,]);
	for(n in 1:N_m) {
		cat(sprintf("%s : %d\n", words[[doc[n]]], z_m_n[[m]][n]))
	}
}
print(phi);
sink();
theta

