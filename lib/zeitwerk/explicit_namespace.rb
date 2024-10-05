# frozen_string_literal: true

module Zeitwerk
  # Centralizes the logic needed to descend into matching subdirectories right
  # after the constant for an explicit namespace has been defined.
  #
  # The implementation assumes an explicit namespace is managed by one loader.
  # Loaders that reopen namespaces owned by other projects are responsible for
  # loading their constant before setup. This is documented.
  module ExplicitNamespace # :nodoc: all
    # Maps cnames to their corresponding namespace name and loader. Entries are
    # added as the namespaces are found, and removed as they are autoloaded.
    #
    # @sig Hash[Symbol => Hash[String, Zeitwerk::Loader]]
    @cpaths = Hash.new { |h, k| h[k] = {} }

    class << self
      include RealModName
      extend Internal

      # @sig (Module, Symbol) -> void
      internal def on_const_added(mod, cname)
        if loader = loader_for(mod, cname)
          namespace = mod.const_get(cname, false)
          loader.on_namespace_loaded(namespace)
        end
      end

      # Asserts `cpath` corresponds to an explicit namespace for which `loader`
      # is responsible.
      #
      # @sig (String, Zeitwerk::Loader) -> void
      internal def register(cref, loader)
        @cpaths[cref.cname][real_mod_name(cref.mod)] = loader
      end

      # @sig (Zeitwerk::Loader) -> void
      internal def unregister_loader(loader)
        @cpaths.delete_if do |cname, h|
          h.delete_if { _2.equal?(loader) }
          h.empty?
        end
      end

      # This is an internal method only used by the test suite.
      #
      # @sig (String) -> bool
      internal def registered?(mod, cname)
        @cpaths.dig(cname, real_mod_name(mod))
      end

      # This is an internal method only used by the test suite.
      #
      # @sig () -> void
      internal def clear
        @cpaths.clear
      end

      # Returns the loader registerd for cpath, if any. This method deletes
      # cpath from @cpath if present.
      #
      # @sig (String) -> Zeitwerk::Loader?
      private def loader_for(mod, cname)
        if h = @cpaths[cname]
          h.delete(real_mod_name(mod))
        end
      end

      module Synchronized
        extend Internal

        MUTEX = Mutex.new

        internal def register(...)
          MUTEX.synchronize { super }
        end

        internal def unregister_loader(...)
          MUTEX.synchronize { super }
        end

        private def loader_for(...)
          MUTEX.synchronize { super }
        end
      end

      prepend Synchronized unless RUBY_ENGINE == "ruby"
    end
  end
end
