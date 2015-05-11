require 'stretchy/types/base'

module Stretchy
  module Types
    class GeoPoint < Base

      attr_reader :lat, :lon

      contract lat: { type: :lat, required: true },
               lon: { type: :lng, required: true }


      def initialize(options = {})
        @lat = options[:lat] || options[:latitude]
        @lon = options[:lng] || options[:lon] ||
               options[:longitude]

        validate!
      end

      def to_search
        {
          lat: @lat,
          lon: @lon
        }
      end

    end
  end
end