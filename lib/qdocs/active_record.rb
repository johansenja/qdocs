module Qdocs
  module ActiveRecord
    module Helpers
      def active_record_column_for(constant, name)
        name = name.to_sym
        col_attrs = constant.column_for_attribute(name)
        if col_attrs.is_a? ::ActiveRecord::ConnectionAdapters::NullColumn
          raise UnknownMethodError, "Unknown attribute #{name} for #{constant}"
        end

        {
          type: col_attrs.sql_type_metadata.type,
          comment: col_attrs.comment,
          default: col_attrs.default,
          null: col_attrs.null,
          default_function: col_attrs.default_function,
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
            klass.attribute_names.each do |name|
              database_attributes[name] = active_record_column_for klass, name
            end
          end
        end

        if constant
          {
            **resp,
            type: :active_record_class,
            attributes: {
              **resp[:attributes],
              database_attributes: database_attributes
            }
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
            klass.attribute_names.grep(pattern).each do |name|
              database_attributes[name] = active_record_column_for klass, name
            end
          end
        end

        if database_attributes.empty?
          attrs
        else
          { **attrs, database_attributes: database_attributes }
        end
      end

      def show(const, meth, type)
        constant = nil
        super do |klass|
          constant = klass
        end
      rescue NameError => e
        raise e unless constant && meth && type == :instance

        if_active_record(constant) do |klass|
          m = meth.is_a?(Method) ? (meth.name rescue nil) : meth
          render_response(klass, :active_record_attribute, active_record_column_for(klass, m))
        end
      end
    end
  end
end
