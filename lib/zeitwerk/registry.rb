# frozen_string_literal: true

module Zeitwerk
  module Registry # :nodoc: all
    require_relative "registry/autoloads"

    class << self
      # Keeps track of all loaders. Useful to broadcast messages and to prevent
      # them from being garbage collected.
      #
      # @private
      # @sig Array[Zeitwerk::Loader]
      attr_reader :loaders

      # Registers gem loaders to let `for_gem` be idempotent in case of reload.
      #
      # @private
      # @sig Hash[String, Zeitwerk::Loader]
      attr_reader :gem_loaders_by_root_file

      # Registers a loader.
      #
      # @private
      # @sig (Zeitwerk::Loader) -> void
      def register_loader(loader)
        loaders << loader
      end

      # @private
      # @sig (Zeitwerk::Loader) -> void
      def unregister_loader(loader)
        loaders.delete(loader)
        gem_loaders_by_root_file.delete_if { |_, l| l == loader }
      end

      # This method returns always a loader, the same instance for the same root
      # file. That is how Zeitwerk::Loader.for_gem is idempotent.
      #
      # @private
      # @sig (String) -> Zeitwerk::Loader
      def loader_for_gem(root_file, namespace:, warn_on_extra_files:)
        gem_loaders_by_root_file[root_file] ||= GemLoader.__new(root_file, namespace: namespace, warn_on_extra_files: warn_on_extra_files)
      end
    end

    @loaders                  = []
    @gem_loaders_by_root_file = {}
  end
end
