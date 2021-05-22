module Qdocs
  module ActiveRecord
    module Helpers
      def active_record_attributes_for(col)
        if col.is_a? ::ActiveRecord::ConnectionAdapters::NullColumn
          raise UnknownMethodError, "Unknown attribute #{col.name}"
        end

        {
          type: col.sql_type_metadata&.type,
          comment: col.comment,
          default: col.default,
          null: col.null,
          default_function: col.default_function,
          name: col.name,
        }
      end

      def if_active_record(constant)
        if Object.const_defined?("::ActiveRecord::Base") && constant < ::ActiveRecord::Base
          yield constant
        end
      end
    end

    class Const < Qdocs::Base::Const
      include ActiveRecord::Helpers

      def show(const)
        database_attributes = {}
        constant = nil
        resp = super do |con|
          if_active_record(con) do |klass|
            constant = klass
            klass.columns.each do |col|
              active_record_attributes_for col
            end
          end
        end

        if constant
          {
            **resp,
            type: :active_record_class,
            attributes: {
              **resp[:attributes],
              database_attributes: database_attributes,
            },
          }
        else
          resp
        end
      end
    end

    class Method < Qdocs::Base::Method
      include ActiveRecord::Helpers

      def index(const, pattern)
        database_attributes = {}
        attrs = super do |constant|
          if_active_record(constant) do |klass|
            klass.columns.each do |col|
              next unless col.name.to_s.match? pattern

              database_attributes[col.name.to_sym] = active_record_attributes_for col
            end
          end
        end

        if database_attributes.empty?
          attrs
        else
          {
            **attrs,
            attributes: {
              **attrs[:attributes],
              database_attributes: database_attributes,
            },
          }
        end
      end

      def show(const, meth, type)
        constant = []
        super do |klass|
          constant << klass
        end
      rescue UnknownMethodError => e
        if constant[0] && meth && type == :instance
          if_active_record(constant[0]) do |klass|
            m = meth.is_a?(::Method) ? (meth.name rescue nil) : meth
            return render_response(
                     klass,
                     :active_record_attribute,
                     active_record_attributes_for(klass.column_for_attribute(m))
                   )
          end
        end

        raise e
      end
    end
  end
end
