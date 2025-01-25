module Zeitwerk::Registry
  # @private
  class Autoloads
    @autoload_paths = {}
    @crefs          = {}
    @loaders        = Hash.new { |h, k| h[k] = Set.new }

    def self.register(loader:, cref:, autoload_path:)
      @autoload_paths[autoload_path] = [loader, cref]
      @loaders[loader] << cref.path
      @crefs[cref.path] = autoload_path
    end

    def self.loader_and_cref_for(path)
      @autoload_paths[path]
    end

    def self.loader_for(path)
      @autoload_paths[path]&.first
    end

    def self.cref_for(path)
      @autoload_paths[path]&.last
    end

    def self.autoload_paths_set_by(loader)
      @loaders[loader].map { @crefs[_1] }
    end

    def self.autoload_path_for(cref)
      @crefs[cref.path]
    end

    def self.autoload_path_set_by_loader_for(loader, cref)
      @loaders[loader].member?(cref.path) && @crefs[cref.path]
    end

    def self.unregister(autoload_path)
      loader, cref = @autoload_paths.delete(autoload_path)
      if loader
        @loaders[loader].delete(cref.path)
        @crefs.delete(cref.path)
      end
    end

    def self.unregister_all(loader)
      if cpaths = @loaders.delete(loader)
        cpaths.each do |cpath|
          autoload_path = @crefs.delete(cpath)
          loader_cref = @autoload_paths.delete(autoload_path)
          yield loader_cref[1], autoload_path if block_given?
        end
      end
    end

    # Used by the test suite.
    def self.empty?
      @autoload_paths.empty?
    end

    # Used by the test suite.
    def self.clear
      @autoload_paths.clear
      @crefs.clear
      @loaders.clear
    end

    # This module is used by `Kernel#require`, which is a hot path. This ad-hoc
    # constant is meant to be used there. The regular constant path is fine in
    # the rest of the gem.
    ::ZEITWERK_REGISTRY_AUTOLOADS = self
  end
end
