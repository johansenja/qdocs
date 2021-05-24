# frozen_string_literal: true

require "method_source"
require_relative "qdocs/version"
require "pathname"

module Qdocs
  class UnknownClassError < StandardError; end

  class UnknownMethodTypeError < StandardError; end

  class UnknownMethodError < StandardError; end

  class UnknownPatternError < StandardError; end

  class InvalidArgumentError < StandardError; end

  module Helpers
    def source_location_to_str(source_location)
      if source_location && source_location.length == 2
        "#{source_location[0]}:#{source_location[1]}"
      end
    end

    def own_methods(methods)
      methods - Object.methods
    end

    def params_to_hash(params)
      hsh = {}
      params.each_with_index do |prm, i|
        hsh[prm[1] || "unnamed_arg_#{i}"] = prm[0]
      end
      hsh
    end

    def find_constant(const)
      case const
      when Symbol, String
        Object.const_get const
      else
        const
      end
    rescue NameError
      raise UnknownClassError, "Unknown constant #{const}"
    end

    def render_response(const, type, attrs)
      {
        original_input: @original_input,
        constant: {
          name: const.name,
          type: const.class.name,
        },
        query_type: type,
        attributes: attrs,
      }
    end
  end

  module Base
    class Const
      include Helpers

      def initialize(original_input)
        @original_input = original_input
      end

      def show(const)
        const = const.to_s
        constant = find_constant const
        yield constant if block_given?

        const_sl = Object.const_source_location const

        if constant.instance_of?(Class) ||
           constant.instance_of?(Module)
          render_response(constant, :constant, {
            source_location: source_location_to_str(const_sl),
            instance_methods: own_methods(constant.instance_methods).sort,
            singleton_methods: own_methods(constant.methods).sort,
            included_modules: constant.included_modules,
            constants: constant.constants,
            constant_type: constant.class.name,
            inheritance_chain: build_inheritance_chain(constant).map(&:name),
          })
        else
          render_response(constant, :constant, {
            source_location: source_location_to_str(const_sl),
            instance_methods: nil,
            singleton_methods: nil,
            included_modules: nil,
            constants: nil,
            value: constant,
            constant_type: constant.class.name,
          })
        end
      end

      private

      def build_inheritance_chain(initial)
        chain = [initial]
        klass = initial
        while klass.respond_to?(:superclass)
          break unless (sc = klass.superclass)

          chain << sc
          klass = sc
        end
        chain
      end
    end

    class Method
      include Helpers

      def initialize(original_input)
        @original_input = original_input
      end

      def index(const, pattern)
        constant = find_constant const

        yield constant if block_given?

        render_response(constant, :methods, {
          constant: constant,
          singleton_methods: own_methods(constant.methods.grep(pattern)).sort,
          instance_methods: own_methods(constant.instance_methods.grep(pattern)).sort,
        })
      end

      def show(const, meth, type)
        constant = find_constant(const)

        yield constant if block_given?

        method = case meth
          when Symbol, String
            method_method = case type
              when :instance
                :instance_method
              when :singleton, :class
                :method
              else
                raise UnknownMethodTypeError, "Unknown method type #{type}"
              end

            begin
              constant.send method_method, meth
            rescue NameError
              raise UnknownMethodError, "No method #{meth.inspect} for #{constant}. Did you mean #{constant}/#{meth}/ ?"
            end
          when ::Method, UnboundMethod
            meth
          else
            raise InvalidArgumentError, "#{meth.inspect} must be of type Symbol, String, or Method"
          end

        parameters = params_to_hash(method.parameters)
        src = method.source rescue nil
        source = if src
            lines = src.lines
            first_line = lines.first
            indent_amount = first_line.length - first_line.sub(/^\s*/, "").length
            lines.map { |l| l[indent_amount..-1] }.join
          end
        sup = method.super_method

        render_response(constant, method_method, {
          defined_at: source_location_to_str(method.source_location),
          source: source,
          arity: method.arity,
          parameters: parameters,
          comment: (method.comment.strip rescue nil),
          name: method.name,
          belongs_to: method.owner,
          super_method: sup ? Handler::Method.new(@original_input).show(sup.owner, sup, type) : nil,
        })
      end
    end
  end

  METHOD_REGEXP = /(?:[a-zA-Z_]+|\[\])[?!=]?/.freeze
  CONST_REGEXP = /[[:upper:]]\w*(?:::[[:upper:]]\w*)*/.freeze

  def self.load_env(dir_level = nil)
    check_dir = dir_level || ["."]
    project_top_level = Pathname(File.join(*check_dir, "Gemfile")).exist? ||
                        Pathname(File.join(*check_dir, ".git")).exist?
    if project_top_level && Pathname(File.join(*check_dir, "config", "environment.rb")).exist?
      require File.join(*check_dir, "config", "environment.rb")
    elsif project_top_level
      # no op - no env to load
    else
      dir_level ||= []
      dir_level << ".."
      Qdocs.load_env(dir_level)
    end
  end

  load_env

  Handler = if Object.const_defined? :ActiveRecord
      require_relative "qdocs/active_record"
      Qdocs::ActiveRecord
    else
      Qdocs::Base
    end

  def self.lookup(input)
    case input
    when /\A([[:lower:]](?:#{METHOD_REGEXP})?)\z/
      Handler::Method.new(input).show(Object, $1, :instance)
    when /\A(#{CONST_REGEXP})\.(#{METHOD_REGEXP})\z/
      Handler::Method.new(input).show($1, $2, :singleton)
    when /\A(#{CONST_REGEXP})#(#{METHOD_REGEXP})\z/
      Handler::Method.new(input).show($1, $2, :instance)
    when /\A(#{CONST_REGEXP})\z/
      Handler::Const.new(input).show($1)
    when %r{\A(#{CONST_REGEXP})/([^/]+)/\z}
      Handler::Method.new(input).index($1, Regexp.new($2))
    else
      raise UnknownPatternError, "Unrecognised pattern #{input}"
    end
  end
end
