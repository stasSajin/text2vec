#include "text2vec.h"
#include "hash.h"
#include "Document.hpp"
#include "Corpus.hpp"

// implements hashing trick
void process_term_hash (const string &term,
                        unordered_map<uint32_t, int> &term_count_map,
                        uint32_t buckets_size,
                        int signned_hash = 0) {
  uint32_t term_id = murmurhash3_hash(term) % buckets_size;

  if(signned_hash) {
    if(murmurhash3_sign(term) >= 0) {
      ++term_count_map[term_id];
    }
    else {
      --term_count_map[term_id];
    }
  }
  else {
    ++term_count_map[term_id];
  }
}

class HashCorpus: public Corpus {
public:
  // constructor
  HashCorpus(uint32_t size, int use_signed_hash) {
    doc_count = 0;
    token_count = 0;
    buckets_size = size;
    signed_hash = use_signed_hash;
  };
  // total number of tokens in corpus
  int get_token_count() {return this->get_token_count();};
  // total number of documents in corpus
  int get_doc_count() { return doc_count; };

  void insert_document(const vector<string> &terms, int ngram_min, int ngram_max, const string ngram_delim = "_") {

    unordered_map<uint32_t, int> term_count_map;
    // simple unigrams
    // ngram also can process unigrams,
    // but following "if" state used for performance reasons
    if(ngram_min == 1 && ngram_max == 1) {
      // iterate trhough input global_terms
      for (auto term : terms) {
        process_term_hash(term, term_count_map, this-> buckets_size, this -> signed_hash);
      }
    }
    // harder case - n-grams
    else {
      //lamda which defines how to process each ngram term
      std::function<void(string)> process_term_fun = [&](string x) {
        process_term_hash(x, term_count_map, this-> buckets_size, this -> signed_hash);
      };
      ngram(terms,
            process_term_fun,
            ngram_min, ngram_max,
            ngram_delim);
    }

    insert_dtm_doc(term_count_map);
  }

  void insert_document_batch(const vector< vector <string > >  docs, int ngram_min, int ngram_max, const string ngram_delim = "_") {
    for (auto it:docs)
      insert_document(it, ngram_min, ngram_max, ngram_delim);
    //Rprintf("token_count = %d\n", token_count);
  }
  // R's interface to document-term matrix construction
  SEXP get_dtm(int type) {
    switch (type) {
    case 0:
      return get_dtm_dgT (buckets_size);
    case 1:
      return get_dtm_lda_c();
    case 2:
      return get_dtm_minhash();
    default:
      return R_NilValue;
    }
  }

private:
  uint32_t buckets_size;
  int signed_hash;
};
