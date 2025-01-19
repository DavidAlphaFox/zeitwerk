# frozen_string_literal: true

require "test_helper"

class TestAutoloads < Minitest::Test
  def setup
    @autoloads      = Zeitwerk::Loader::Autoloads.new
    @autoload_path  = "/m.rb"
    @autoload_path2 = "/n.rb"
    @cref           = Zeitwerk::Cref.new(Object, :M)
    @cref2          = Zeitwerk::Cref.new(Object, :N)
  end

  test "define defines an autoload" do
    on_teardown { remove_const :M }

    @autoloads.define(@cref, @autoload_path)
    assert_equal @autoload_path, @cref.autoload?
  end

  test "autoload_path_for returns the configured autoload path" do
    on_teardown { remove_const :M }

    @autoloads.define(@cref, @autoload_path)
    assert_equal @autoload_path, @autoloads.autoload_path_for(@cref)
    assert_nil @autoloads.autoload_path_for(@cref2)
  end

  test "cref_for returns the configured cref" do
    on_teardown { remove_const :M }

    @autoloads.define(@cref, @autoload_path)
    assert_equal @cref, @autoloads.cref_for(@autoload_path)
    assert_nil @autoloads.cref_for(@autoload_path2)
  end

  test "each iterates over the autoloads" do
    on_teardown { remove_const :M }

    @autoloads.define(@cref, @autoload_path)
    @autoloads.each do |cref, autoload_path|
      assert_equal @autoload_path, autoload_path
      assert_equal Object, cref.mod
      assert_equal :M, cref.cname
    end
  end

  test "delete maintains the two internal collections" do
    on_teardown { remove_const :M }

    @autoloads.define(@cref, @autoload_path)
    @autoloads.delete(@autoload_path)
    assert @autoloads.empty?
  end

  test "a new instance is empty" do
    assert @autoloads.empty?
  end

  test "an instance with definitions is not empty" do
    on_teardown { remove_const :M }

    @autoloads.define(@cref, @autoload_path)
    assert !@autoloads.empty?
  end

  test "a cleared instance is empty" do
    on_teardown { remove_const :M }

    @autoloads.define(@cref, @autoload_path)
    @autoloads.clear
    assert @autoloads.empty?
  end
end
