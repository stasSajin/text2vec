% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dtm.R
\name{create_dtm}
\alias{create_dtm}
\alias{create_dtm.itoken}
\alias{create_dtm.list}
\title{Document-term matrix construction}
\usage{
create_dtm(it, vectorizer, type = c("dgCMatrix", "dgTMatrix", "lda_c"), ...)

\method{create_dtm}{itoken}(it, vectorizer, type = c("dgCMatrix", "dgTMatrix",
  "lda_c"), ...)

\method{create_dtm}{list}(it, vectorizer, type = c("dgCMatrix", "dgTMatrix",
  "lda_c"), verbose = FALSE, ...)
}
\arguments{
\item{it}{\link{itoken} iterator or \code{list} of \code{itoken} iterators.}

\item{vectorizer}{\code{function} vectorizer function; see
\link{vectorizers}.}

\item{type}{\code{character}, one of \code{c("dgCMatrix", "dgTMatrix",
"lda_c")}. \code{"lda_c"} is Blei's lda-c format (a list of 2 *
doc_terms_size); see
\url{https://www.cs.princeton.edu/~blei/lda-c/readme.txt}}

\item{...}{arguments to the \link{foreach} function which is used to iterate
over \code{it}.}

\item{verbose}{\code{logical} print status messages}
}
\value{
A document-term matrix
}
\description{
This is a high-level function for creating a document-term
  matrix.
}
\details{
If a parallel backend is registered and first argument is a list of \code{itoken},
itereators, fucntion will construct the DTM in multiple threads.
User should keep in mind that he or she should split the data itself and provide a list of
\link{itoken} iterators. Each element of \code{it} will be handled in separate
thread and combined at the end of processing.
}
\examples{
\dontrun{
data("movie_review")
N = 1000
it = itoken(movie_review$review[1:N], preprocess_function = tolower,
             tokenizer = word_tokenizer)
v = create_vocabulary(it)
#remove very common and uncommon words
pruned_vocab = prune_vocabulary(v, term_count_min = 10,
 doc_proportion_max = 0.5, doc_proportion_min = 0.001)
vectorizer = vocab_vectorizer(v)
it = itoken(movie_review$review[1:N], preprocess_function = tolower,
             tokenizer = word_tokenizer)
dtm = create_dtm(it, vectorizer)
# get tf-idf matrix from bag-of-words matrix
dtm_tfidf = transformer_tfidf(dtm)

## Example of parallel mode
# set to number of cores on your machine
N_WORKERS = 1
doParallel::registerDoParallel(N_WORKERS)
splits = split_into(movie_review$review, N_WORKERS)
jobs = lapply(splits, itoken, tolower, word_tokenizer, chunks_number = 1)
vectorizer = hash_vectorizer()
dtm = create_dtm(jobs, vectorizer, type = 'dgTMatrix')
}
}
\seealso{
\link{itoken} \link{vectorizers}
}

