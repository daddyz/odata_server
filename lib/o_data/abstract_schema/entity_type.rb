require_relative 'mixins/serializable'
require_relative 'mixins/schematize'

module OData
  module AbstractSchema
    class EntityType
      include Mixins::Serializable::EntityTypeInstanceMethods
      include Mixins::Schematize

      attr_reader :key_property, :schema
      attr_accessor :properties, :navigation_properties, :name

      def initialize(schema, name)
        @schema = schema
        @name = name
        @properties = []
        @key_property = nil
        @navigation_properties = []
      end

      def key_property=(property)
        return nil unless property.is_a?(Property)
        return nil unless @properties.include?(property)
        @key_property = property
      end

      def Property(*args)
        property = Property.new(self, *args)
        @properties << property
        property
      end

      def NavigationProperty(*args)
        navigation_property = NavigationProperty.new(self, *args)
        @navigation_properties << navigation_property
        navigation_property
      end

      def find_property(property_name)
        @properties.find { |p| p.name == property_name }
      end

      def find_all(key_values = {}, options = nil)
        []
      end

      def find_one(key_value)
        return nil if @key_property.blank?
        find_all(@key_property => key_value).first
      end

      def exists?(key_value)
        !!find_one(key_value)
      end

      def href_for(one)
        @name + '(' + primary_key_for(one).to_s + ')'
      end

      def primary_key_for(one)
        return nil if @key_property.blank?
        @key_property.value_for(one)
      end

      def inspect
        "#<< #{qualified_name.to_s}(#{[@properties, @navigation_properties].flatten.collect { |p| "#{p.name.to_s}: #{p.return_type.to_s}" }.join(', ')}) >>"
      end

      def filter(results, filter)
        results.collect do |entity|
          filter.apply(self, entity)
        end.compact
      end
    end
  end
end
