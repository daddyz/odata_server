module OData
  module Core
    module Segments
      class PropertySegment < EntityTypeSegment
        attr_reader :property

        def self.parse!(query, str)
          return nil if query.segments.empty?
          return nil unless query.segments.last.respond_to?(:entity_type)
          entity_type = query.segments.last.entity_type
          return nil if entity_type.nil?
          property = entity_type.find_property(str)
          return nil if property.blank?

          query.Segment(self, entity_type, property)
        end

        def initialize(query, entity_type, property)
          @property = property

          super(query, entity_type, @property.name)
        end

        def self.can_follow?(anOtherSegment)
          if anOtherSegment.is_a?(Class)
            anOtherSegment == CollectionSegment || anOtherSegment == NavigationPropertySegment
          else
            (anOtherSegment.is_a?(CollectionSegment) || anOtherSegment.is_a?(NavigationPropertySegment)) && !anOtherSegment.countable?
          end
        end

        def countable?
          false
        end

        def execute!(acc, options = nil)
          { @property => @property.value_for(Array(acc).compact.first) }
        end

        def valid?(results)
          # results.is_a?(Array)
          !results.blank?
        end
      end # PropertySegment
    end # Segments
  end # Core
end # OData
