# frozen_string_literal: true

module Zeitwerk::ExplicitNamespacesRegistry
  def const_added(cname)
    # Module#const_added is triggered when an autoload is defined too. We are
    # only interested in constants that are defined for real. In the case of
    # inceptions we get a false nil, but this is covered in the loader by doing
    # things in a certain order.
    unless autoload?(cname, false)
      Zeitwerk::ExplicitNamespace.__on_const_added(self, cname)
    end
    super
  end

  Module.prepend(self)
end
