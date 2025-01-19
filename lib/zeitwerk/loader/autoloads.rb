# frozen_string_literal: true

class Zeitwerk::Loader::Autoloads
  # @sig () -> void
  def initialize
    # Maps crefs for which an autoload has been set, to their respective
    # autoload paths. Entries look like this:
    #
    #   #<Zeitwerk::Cref:... @mod=Object, @cname=:User, ...> => ".../app/models/user.rb"
    #   #<Zeitwerk::Cref:... @mod=Hotel, @cname=:Pricing, ...> => ".../app/models/hotel/pricing.rb"
    #
    # I would expect this collection to not be necessary, since it is basically
    # doing what Module#autoload? already does. However, there is an edge case
    # in which Module#autoload? returns nil for an autoload just set. See
    #
    #   https://bugs.ruby-lang.org/issues/21035
    #
    # @sig Hash[Zeitwerk::Cref, String]
    @c2a = {}

    # This is the inverse of `c2a`.
    #
    # @sig Hash[String, Zeitwerk::Cref]
    @a2c = {}
  end

  # @sig (Zeitwerk::Cref, String) -> void
  def define(cref, autoload_path)
    cref.autoload(autoload_path)
    @c2a[cref] = autoload_path
    @a2c[autoload_path] = cref
  end

  # @sig () { () -> (Zeitwerk::Cref, String) } -> void
  def each(&block)
    @c2a.each(&block)
  end

  # @sig (Zeitwerk::Cref) -> String?
  def autoload_path_for(cref)
    @c2a[cref]
  end

  # @sig (String) -> Zeitwerk::Cref?
  def cref_for(autoload_path)
    @a2c[autoload_path]
  end

  # @sig (String) -> Zeitwerk::Cref?
  def delete(abspath)
    cref = @a2c.delete(abspath)
    @c2a.delete(cref)
    cref
  end

  # @sig () -> void
  def clear
    @c2a.clear
    @a2c.clear
  end

  # @sig () -> bool
  def empty?
    @c2a.empty? && @a2c.empty?
  end
end
