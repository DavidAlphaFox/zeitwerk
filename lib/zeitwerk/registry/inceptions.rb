module Zeitwerk::Registry
  module Inceptions
    # @sig Hash[String, String]
    @inceptions = {}

    class << self
      def register(cpath, autoload_path)
        @inceptions[cpath] = autoload_path
      end

      def registered?(cpath)
        @inceptions[cpath]
      end

      def unregister(cpath)
        @inceptions.delete(cpath)
      end

      def clear # for tests
        @inceptions.clear
      end
    end
  end
end
