# frozen_string_literal: true

module Zeitwerk::ConstAdded # :nodoc:
  #: (Symbol) -> void
  def const_added(cname)
    if loader = Zeitwerk::Registry.explicit_namespaces.loader_for(self, cname) ## 找到队形类明的加载器
      namespace = const_get(cname, false) #检查模块内是否有对应的常量，不向祖先类内部进行搜索
      cref = Zeitwerk::Cref.new(self, cname)

      unless namespace.is_a?(Module)
        raise Zeitwerk::Error, "#{cref} is expected to be a namespace, should be a class or module (got #{namespace.class})"
      end

      loader.__on_namespace_loaded(cref, namespace)
    end
    super
  end
  #将自己的const_add放在调用链路前面，这样会先调用自己的const_added，然后再调用Ruby Module中的const_added
  #这样就可以拦截到类或者模块加载的动作
  Module.prepend(self)
end
