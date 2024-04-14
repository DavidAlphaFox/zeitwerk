class Zeitwerk::NullInflector
  # See the rationale for the third optional argument in
  # Zeitwerk::Inflector#camelize.
  #
  # @sig (String, String, String?) -> String
  def camelize(basename, _abspath, _namespace = nil)
    basename
  end
end
