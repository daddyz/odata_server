module OData
  module ActiveRecordSchema
    class Property < OData::AbstractSchema::Property
      cattr_reader :column_adapter_return_types
      @@column_adapter_return_types = {
        :binary    => 'Edm.Binary',
        :boolean   => 'Edm.Boolean',
        :byte      => 'Edm.Byte',
        :date      => 'Edm.Date',
        :datetime  => 'Edm.DateTime',
        :float     => 'Edm.Decimal',
        :decimal   => 'Edm.Decimal',
        :integer   => 'Edm.Int32',
        :string    => 'Edm.String',
        :text      => 'Edm.String',
        :timestamp => 'Edm.DateTime',
        :time      => 'Edm.Time'
      }.freeze

      attr_reader :column_adapter

      def initialize(entity_type, column_adapter)
        super(entity_type, self.class.name_for(column_adapter), self.class.return_type_for(column_adapter), self.class.nullable?(column_adapter))

        @column_adapter = column_adapter
      end

      def self.return_type_for(column_adapter)
        @@column_adapter_return_types[column_adapter.type]
      end

      def self.name_for(column_adapter)
        column_adapter.name.to_s
      end

      def self.nullable?(column_adapter)
        column_adapter.null
      end

      def value_for(one)
        v = one.send(@column_adapter.name.to_sym)
        return v.to_datetime.strftime('%Y-%m-%dT%H:%M:%S') if v.class == ActiveSupport::TimeWithZone
        return v.to_s if return_type == 'Edm.Decimal'
        v.respond_to?(:iso8601) ? v.send(:iso8601) : v
      end
    end
  end
end
