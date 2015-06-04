require 'stretchy/queries/base'

module Stretchy
  module Queries
    class MatchQuery < Base

      OPERATORS   = ['and', 'or']
      MATCH_TYPES = ['phrase', 'phrase_prefix']

      attribute :field,     String, default: '_all'
      attribute :string,    String
      attribute :operator,  String
      attribute :type,      String
      attribute :slop,      Integer
      attribute :min,       String
      attribute :max,       Float

      validations do
        rule :field,    :field
        rule :string,    type: String
        rule :string,   :required
        rule :operator,  inclusion: {in: OPERATORS}
        rule :type,      inclusion: {in: MATCH_TYPES}
        rule :slop,      type: Numeric
        rule :min,       regular_expression: {regex: /\A(\d+)%?\Z/}
        rule :max,       type: Numeric
      end

      def option_attributes
        return @opts if @opts
        @opts = {}
        @opts[:query]                = @string
        @opts[:type]                 = @type       if @type
        @opts[:operator]             = @operator   if @operator
        @opts[:minimum_should_match] = @min        if @min
        @opts[:slop]                 = @slop       if @slop && MATCH_TYPES.include?(@type)
        @opts[:max_expansions]       = @max        if @max && @type == 'phrase_prefix'
        @opts
      end

      def to_search
        {
          match: {
            @field => option_attributes,
          }
        }
      end

    end
  end
end
