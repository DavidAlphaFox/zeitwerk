# frozen_string_literal: true

require "test_helper"

class TestForNamespacedGem < LoaderTest
  MY_NAMESPACED_GEM_FILES = []
  MY_NAMESPACED_GEM_FILES << ["lib/my_org-my_namespaced_gem.rb", <<~EOS]
    require "my_org/my_namespaced_gem"
  EOS
  MY_NAMESPACED_GEM_FILES << ["lib/my_org/my_namespaced_gem.rb", <<~EOS]
    $for_namespaced_gem_test_loader = Zeitwerk::Loader.for_namespaced_gem
    $for_namespaced_gem_test_loader.enable_reloading
    $for_namespaced_gem_test_loader.setup

    module MyOrg
      module MyNamespacedGem
      end
    end
  EOS

  MY_NAMESPACED_GEM_FILES << ["lib/my_org/my_namespaced_gem/version.rb", <<~EOS]
    module MyOrg
      module MyNamespacedGem
        VERSION = "1.0"
      end
    end
  EOS

  test "autoloads the gem (convenience entry point)" do
    with_files(MY_NAMESPACED_GEM_FILES) do
      with_load_path("lib") do
        assert require("my_org-my_namespaced_gem")
        assert_equal "1.0", MyOrg::MyNamespacedGem::VERSION
      end
    end
  end

  test "autoloads the gem (main entry point)" do
    with_files(MY_NAMESPACED_GEM_FILES) do
      with_load_path("lib") do
        assert require("my_org/my_namespaced_gem")
        assert_equal "1.0", MyOrg::MyNamespacedGem::VERSION
      end
    end
  end
end
