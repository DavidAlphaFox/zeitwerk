# frozen_string_literal: true

module Zeitwerk::ExplicitNamespacesRegistry
  def const_added(cname)
    Zeitwerk::ExplicitNamespace.__on_const_added(self, cname)
    super
  end

  Module.prepend(self)
end
