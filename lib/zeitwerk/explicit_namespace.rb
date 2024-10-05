# frozen_string_literal: true

module Zeitwerk
  # Centralizes the logic needed to descend into matching subdirectories right
  # after the constant for an explicit namespace has been defined.
  #
  # The implementation assumes an explicit namespace is managed by one loader.
  # Loaders that reopen namespaces owned by other projects are responsible for
  # loading their constant before setup. This is documented.
  module ExplicitNamespace # :nodoc: all
    # Maps cpaths of explicit namespaces with their corresponding loader.
    # Entries are added as the namespaces are found, and removed as they are
    # autoloaded.
    #
    # @sig Hash[String => Zeitwerk::Loader]
    @cpaths = {}

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
      internal def register(cpath, loader)
        @cpaths[cpath] = loader
      end

      # @sig (Zeitwerk::Loader) -> void
      internal def unregister_loader(loader)
        @cpaths.delete_if { _2.equal?(loader) }
      end

      # This is an internal method only used by the test suite.
      #
      # @sig (String) -> bool
      internal def registered?(cpath)
        @cpaths[cpath]
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
        # @cpaths.empty? is cheap and, depending on the code base, often true.
        #
        # Note that due to the way Zeitwerk works, namespaces are registered
        # necessarily before their constant is defined, so the race codintion
        # due to the gap from here to the delete call down below would not
        # introduce a logic flaw.
        #
        # On one hand, if @cpaths is empty and a new entry is created after this
        # check, it won't be for mod::cname anyway.
        #
        # On the other hand, if @cpaths is not empty, what happens with @cpaths
        # during the gap is fine, because delete has the last word anyway.
        return if @cpaths.empty?

        # Module#const_added is triggered when an autoload is defined too. This
        # callback is only for constants that are defined for real. In the case
        # of inceptions we get a false nil, but this is covered in the loader by
        # doing things in a certain order.
        return if mod.autoload?(cname, false)

        # I benchmarked this against using pairs [mod, cname] as keys, and
        # strings won.
        cpath = mod.equal?(Object) ? cname.name : "#{real_mod_name(mod)}::#{cname}"
        @cpaths.delete(cpath)
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
