# frozen_string_literal: true

require "test_helper"

class TestForNamespacedGem < LoaderTest
  def my_namespaced_gem_files
    [
      ["lib/my_org-my_namespaced_gem.rb", <<~EOS],
        require "my_org/my_namespaced_gem"
      EOS
      ["lib/my_org/my_namespaced_gem.rb", <<~EOS],
        $for_namespaced_gem_test_loader = Zeitwerk::Loader.for_namespaced_gem
        $for_namespaced_gem_test_loader.enable_reloading
        $for_namespaced_gem_test_loader.setup

        module MyOrg
          module MyNamespacedGem
          end
        end
      EOS
      ["lib/my_org/my_namespaced_gem/version.rb", <<~EOS],
        MyOrg::MyNamespacedGem::VERSION = "1.0"
      EOS
      ["lib/my_org/my_namespaced_gem/foo/bar.rb", <<~EOS]
        module MyOrg::MyNamespacedGem::Foo
          class Bar
          end
        end
      EOS
    ]
  end

  def my_namespaced_gem_with_lib_namespace_files
    [
      ["lib/my_org-lib-my_namespaced_gem.rb", <<~EOS],
        require "my_org/lib/my_namespaced_gem"
      EOS
      ["lib/my_org/lib/my_namespaced_gem.rb", <<~'EOS'],
        lib = File.expand_path("#{__dir__}/../..")
        $for_namespaced_gem_with_lib_test_loader = Zeitwerk::Loader.for_namespaced_gem(lib)
        $for_namespaced_gem_with_lib_test_loader.enable_reloading
        $for_namespaced_gem_with_lib_test_loader.setup

        module MyOrg
          module Lib
            module MyNamespacedGem
            end
          end
        end
      EOS
      ["lib/my_org/lib/my_namespaced_gem/version.rb", <<~EOS],
        MyOrg::Lib::MyNamespacedGem::VERSION = "1.0"
      EOS
      ["lib/my_org/lib/my_namespaced_gem/foo/bar.rb", <<~EOS]
        module MyOrg::Lib::MyNamespacedGem::Foo
          class Bar
          end
        end
      EOS
    ]
  end

  def for_namespaced_gem_with_lib_namespace_assertions
    assert MyOrg::Lib::MyNamespacedGem::Foo::Bar
    assert_equal "1.0", MyOrg::Lib::MyNamespacedGem::VERSION
    $for_namespaced_gem_with_lib_test_loader.tag = "my_org-lib-my_namespaced_gem"
  end

  test "autoloads the gem with a lib namespace (convenience top-level entry point)" do
    on_teardown { delete_loaded_feature("my_org-lib-my_namespaced_gem.rb") }

    with_files(my_namespaced_gem_with_lib_namespace_files) do
      with_load_path("lib") do
        assert require("my_org-lib-my_namespaced_gem")
        for_namespaced_gem_with_lib_namespace_assertions
      end
    end
  end

  test "autoloads the gem with a lib namespace (main entry point)" do
    on_teardown { delete_loaded_feature("my_org/lib/my_namespaced_gem.rb") }

    with_files(my_namespaced_gem_with_lib_namespace_files) do
      with_load_path("lib") do
        assert require("my_org/lib/my_namespaced_gem")
        for_namespaced_gem_with_lib_namespace_assertions
      end
    end
  end
end
