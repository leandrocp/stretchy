require 'spec_helper'

module Stretchy
  describe API do

    it 'makes a filtered query' do
      json = subject.where(url_slug: 'masahiro-sakurai').json
      expect(json).to eq(
        query: { filtered: { filter: {term: {url_slug: 'masahiro-sakurai'}}}}
      )
    end

    it 'does multiple filters' do
      json = subject.where(url_slug: 'masahiro-sakurai', is_sakurai: true).json
      expect(json).to eq(
        query: { filtered: { filter: { bool: {
          must: [
            {term: {url_slug:   'masahiro-sakurai'}},
            {term: {is_sakurai: true}},
          ]
        }}}}
      )
    end

    it 'does a query and filter' do
      json = subject.fulltext(name: 'sakurai')
                    .where(url_slug: 'masahiro-sakurai', is_sakurai: true)
                    .json
      expect(json).to eq(
        query: { filtered: {
          query: { match: { name: { query: 'sakurai'} }},
          filter: { bool: {
            must: [
              {term: {url_slug:   'masahiro-sakurai'}},
              {term: {is_sakurai: true}},
            ]
          }
        }}}
      )
    end

    it 'does a not filter' do
      result = { query: { filtered: { filter: { bool: {
          must_not: [
            {term: {url_slug:   'masahiro-sakurai'}}
          ]
      }}}}}

      json = subject.where.not(url_slug: 'masahiro-sakurai').json
      expect(json).to eq(result)

      json = subject.not.where(url_slug: 'masahiro-sakurai').json
      expect(json).to eq(result)
    end

    it 'does a query, not query, not filter' do
      result = { query: { filtered: {
        query: { bool: {
          must: [{match: { name: {query: 'sakurai'} }}],
          must_not: [{match: {name: {query: 'mizuguchi'}}}]
        }},
        filter: { bool: {
          must_not: [{term: {url_slug: 'tetsuya-mizuguchi'}}]
        }}
      }}}

      json = subject.fulltext(name: 'sakurai')
                    .fulltext.not(name: 'mizuguchi')
                    .where.not(url_slug: 'tetsuya-mizuguchi')
                    .json
      expect(json).to eq(result)
    end

    it 'does a should query' do
      result = { query: { bool: { should: [ {match: {name: {query: 'sakurai'}}}]}}}
      json = subject.fulltext.should(name: 'sakurai').json
      expect(json).to eq(result)
    end

    it 'handles complex stuff' do
      results = {:query=>{:filtered=>{:query=>{:bool=>{:must=>[{:match=>{:name=>{query: "sakurai"}}}], :must_not=>[{:match=>{:name=>{query: "mizuguchi"}}}], :should=>[{:match=>{:company=>{query: "nintendo"}}}]}}, :filter=>{:bool=>{:must=>[{:term=>{:url_slug=>"masahiro-sakurai"}}], :must_not=>[{:term=>{:url_slug=>"tetsuya-mizuguchi"}}], :should=>[{:term=>{:is_sakurai=>true}}]}}}}}

      json = subject.fulltext(name: 'sakurai')
             .fulltext.not(name: 'mizuguchi')
             .fulltext.should(company: 'nintendo')
             .where(url_slug: 'masahiro-sakurai')
             .where.not(url_slug: 'tetsuya-mizuguchi')
             .where.should(is_sakurai: true)
             .json
      expect(json).to eq(results)
    end

    it 'does a boost by filter' do
      results = {:query=>
        {:function_score=>
        {:functions=>[{:term=>{:url_slug=>"masahiro-sakurai"}}],
        :query=>{:match=>{:name=>{query: "sakurai"}}}}}}

      json = subject.fulltext(name: 'sakurai')
                    .boost.where(url_slug: 'masahiro-sakurai')
                    .json
      expect(results).to eq(json)
    end

    it 'does a match phrase query' do
      json = subject.fulltext(name: 'sakurai', meta: {type: :phrase, operator: :and}).json
      expect(json).to eq(query: { match: { name: { query: 'sakurai', type: :phrase, operator: :and}}})
    end

    it 'does an or query' do
      result = {:query=>{:filtered=>{:filter=>{:or=>
       [{:term=>{:url_slug=>"masahiro-sakurai"}},
        {:term=>{:url_slug=>"tetsuya-mizuguchi"}}]}}}}
      json = subject.where(url_slug: 'masahiro-sakurai').or(url_slug: 'tetsuya-mizuguchi').json
      expect(json).to eq(result)
    end

    it 'ors a query with a filter' do
      json = subject.where(url_slug: 'masahiro-sakurai').or.fulltext(name: 'sakurai').json
      pp [:filter_query_or, json]
    end

    it 'does multiple or conditions' do
      json = subject.where(url_slug: 'masahiro-sakurai')
                    .or(salary: 900000)
                    .or(is_sakurai: true)
                    .json
      pp [:multiple_or, json]
    end

    it 'ands together conditions' do
      json = subject.where(url_slug: 'masahiro-sakurai')
                    .or.fulltext(name: 'sakurai')
                    .and.where(salary: 900000)
                    .json
      pp [:or_and, json]
    end

  end
end