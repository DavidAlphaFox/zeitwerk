# frozen_string_literal: true

module Zeitwerk
  class Inflector
    # Very basic snake case -> camel case conversion.
    #
    #   inflector = Zeitwerk::Inflector.new
    #   inflector.camelize("post", abspath, "Object")            # => "Post"
    #   inflector.camelize("users_controller", abspath, "Admin") # => "UsersController"
    #   inflector.camelize("api", abspath, "Object")             # => "Api"
    #
    # Takes into account hard-coded mappings configured with `inflect`.
    #
    # The third argument was added in 2.6.14. It is optional because existing
    # subclasses using the previous signature with two arguments may be calling
    # super(basename, abspath) or just super. We need these to work as they are.
    # At the same time, super for new subclasses defining the new signature is
    # going to work as well.
    #
    # @sig (String, String, String?) -> String
    def camelize(basename, _abspath, _namespace_name = nil)
      overrides[basename] || basename.split('_').each(&:capitalize!).join
    end

    # Configures hard-coded inflections:
    #
    #   inflector = Zeitwerk::Inflector.new
    #   inflector.inflect(
    #     "html_parser"   => "HTMLParser",
    #     "mysql_adapter" => "MySQLAdapter"
    #   )
    #
    #   inflector.camelize("html_parser", abspath, "MyGem")      # => "HTMLParser"
    #   inflector.camelize("users_controller", abspath, "Admin") # => "UsersController"
    #   inflector.camelize("mysql_adapter", abspath, "Object")   # => "MySQLAdapter"
    #
    # @sig (Hash[String, String]) -> void
    def inflect(inflections)
      overrides.merge!(inflections)
    end

    private

    # Hard-coded basename to constant name user maps that override the default
    # inflection logic.
    #
    # @sig () -> Hash[String, String]
    def overrides
      @overrides ||= {}
    end
  end
end
