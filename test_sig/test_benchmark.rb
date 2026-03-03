# frozen_string_literal: true

require "test/unit"
require "rbs/unit_test"
require "benchmark"

class TestBenchmarkModuleSignature < Test::Unit::TestCase
  include RBS::UnitTest::TypeAssertions
  library "benchmark"
  testing "singleton(::Benchmark)"

  def test_constants
    assert_const_type "::String", "Benchmark::BENCHMARK_VERSION"
    assert_const_type "::String", "Benchmark::CAPTION"
    assert_const_type "::String", "Benchmark::FORMAT"
  end

  def test_bm
    suppress_stdout do
      assert_send_type "() { (Benchmark::Report) -> void } -> ::Array[::Benchmark::Tms]",
                      Benchmark, :bm do |r| r end
      assert_send_type "(Integer) { (Benchmark::Report) -> void } -> ::Array[::Benchmark::Tms]",
                      Benchmark, :bm, 1 do |r| r end
      assert_send_type "(Integer, String, String) { (Benchmark::Report) -> void } -> ::Array[::Benchmark::Tms]",
                      Benchmark, :bm, 1, "x", "y" do |r| r end
    end
  end

  def test_bmbm
    suppress_stdout do
      assert_send_type "() { (Benchmark::Job) -> void } -> ::Array[::Benchmark::Tms]",
                       Benchmark, :bmbm do |j| j end
      assert_send_type "(Integer) { (Benchmark::Job) -> void } -> ::Array[::Benchmark::Tms]",
                       Benchmark, :bmbm, 1 do |j| j end
    end
  end

  def test_measure
    assert_send_type "(?::String label) { () -> untyped } -> ::Benchmark::Tms",
                     Benchmark, :measure, "x" do end
  end

  def test_realtime
    assert_send_type "{ () -> untyped } -> ::Float",
                     Benchmark, :realtime do end
  end

  def test_ms
    assert_send_type "() { () -> untyped } -> ::Float",
                     Benchmark, :ms do end
  end

  def suppress_stdout
    stdout = $stdout
    File.open(IO::NULL, "w") do |io|
      $stdout = io
      yield
    end
  ensure
    $stdout = stdout
  end
end

class TestBenchmarkJobSignature < Test::Unit::TestCase
  include RBS::UnitTest::TypeAssertions
  library "benchmark"
  testing "::Benchmark::Job"

  def test_initialize
    assert_send_type "(Integer width) -> void",
                     Benchmark::Job.allocate, :initialize, 1
  end

  def test_item
    job = Benchmark::Job.new(1)
    assert_send_type("(?untyped label) { () -> untyped } -> ::Benchmark::Job",
                     job, :item, "report") { 1 + 1 }
    assert_send_type("(?untyped label) { () -> untyped } -> ::Benchmark::Job",
                     job, :report, "report") { 1 + 1 }
  end

  def test_list
    job = Benchmark::Job.new(1)
    assert_send_type "() -> ::Array[untyped]", job, :list
  end

  def test_width
    job = Benchmark::Job.new(1)
    assert_send_type "() -> ::Integer", job, :width
  end
end

class TestBenchmarkReportSignature < Test::Unit::TestCase
  include RBS::UnitTest::TypeAssertions
  library "benchmark"
  testing "::Benchmark::Report"

  def test_initialize
    assert_send_type "() -> void",
                     Benchmark::Report.allocate, :initialize
    assert_send_type "(Integer width) -> void",
                     Benchmark::Report.allocate, :initialize, 1
    assert_send_type "(Integer width, String format) -> void",
                     Benchmark::Report.allocate, :initialize, 1, "x"
  end

  def test_item
    report = Benchmark::Report.new
    assert_send_type("() { () -> untyped } -> ::Benchmark::Tms",
                     report, :item) { }
    assert_send_type("(String label) { () -> untyped } -> ::Benchmark::Tms",
                     report, :report, "report") { }
    assert_send_type("(String label, String format) { () -> untyped } -> ::Benchmark::Tms",
                     report, :report, "report", "format") { }
  end

  def test_width
    report = Benchmark::Report.new
    assert_send_type "() -> ::Integer", report, :width
  end

  def test_format
    report = Benchmark::Report.new
    assert_send_type "() -> nil", report, :format
  end

  def test_list
    report = Benchmark::Report.new
    assert_send_type "() -> ::Array[::Benchmark::Tms]", report, :list
  end
end

class TestBenchmarkTmsSignature < Test::Unit::TestCase
  include RBS::UnitTest::TypeAssertions
  library "benchmark"
  testing "::Benchmark::Tms"

  def test_initialize
    assert_send_type "() -> void",
                     Benchmark::Tms.allocate, :initialize
    assert_send_type "(Float utime) -> void",
                     Benchmark::Tms.allocate, :initialize, 1.0
    assert_send_type "(Float utime, Float stime) -> void",
                     Benchmark::Tms.allocate, :initialize, 1.0, 2.0
    assert_send_type "(Float utime, Float stime, Float cutime) -> void",
                     Benchmark::Tms.allocate, :initialize, 1.0, 2.0, 3.0
    assert_send_type "(Float utime, Float stime, Float cutime, Float cstime) -> void",
                     Benchmark::Tms.allocate, :initialize, 1.0, 2.0, 3.0, 4.0
    assert_send_type "(Float utime, Float stime, Float cutime, Float cstime, Float real) -> void",
                     Benchmark::Tms.allocate, :initialize, 1.0, 2.0, 3.0, 4.0, 5.0
    assert_send_type "(Float utime, Float stime, Float cutime, Float cstime, Float real, String label) -> void",
                     Benchmark::Tms.allocate, :initialize, 1.0, 2.0, 3.0, 4.0, 5.0, "label"
  end

  def test_utime
    assert_send_type "() -> ::Float", Benchmark::Tms.new, :utime
  end

  def test_stime
    assert_send_type "() -> ::Float", Benchmark::Tms.new, :stime
  end

  def test_cutime
    assert_send_type "() -> ::Float", Benchmark::Tms.new, :cutime
  end

  def test_cstime
    assert_send_type "() -> ::Float", Benchmark::Tms.new, :cstime
  end

  def test_real
    assert_send_type "() -> ::Float", Benchmark::Tms.new, :real
  end

  def test_total
    assert_send_type "() -> ::Float", Benchmark::Tms.new, :total
  end

  def test_label
    assert_send_type "() -> ::String", Benchmark::Tms.new, :label
  end

  def test_multiply
    tms = Benchmark::Tms.new
    assert_send_type "(::Benchmark::Tms) -> ::Benchmark::Tms", tms, :*, tms
    assert_send_type "(Float) -> ::Benchmark::Tms", tms, :*, 2.0
  end

  def test_plus
    tms = Benchmark::Tms.new
    assert_send_type "(::Benchmark::Tms) -> ::Benchmark::Tms", tms, :+, tms
    assert_send_type "(Float) -> ::Benchmark::Tms", tms, :+, 2.0
  end

  def test_minus
    tms = Benchmark::Tms.new
    assert_send_type "(::Benchmark::Tms) -> ::Benchmark::Tms", tms, :-, tms
    assert_send_type "(Float) -> ::Benchmark::Tms", tms, :-, 2.0
  end

  def test_divide
    tms = Benchmark::Tms.new
    assert_send_type "(::Benchmark::Tms) -> ::Benchmark::Tms", tms, :/, tms
    assert_send_type "(Float) -> ::Benchmark::Tms", tms, :/, 2.0
  end

  def test_add
    assert_send_type "() { () -> untyped } -> ::Benchmark::Tms",
                     Benchmark::Tms.new, :add do end
  end

  def test_add!
    assert_send_type "() { () -> untyped } -> ::Benchmark::Tms",
                     Benchmark::Tms.new, :add! do end
  end

  def test_format
    tms = Benchmark::Tms.new
    assert_send_type "() -> ::String", tms, :format
    assert_send_type "(nil) -> ::String", tms, :format, nil
    assert_send_type "(String) -> ::String", tms, :format, "format"
    assert_send_type "(String, Float) -> ::String", tms, :format, "format", 1.0
  end

  def test_to_a
    assert_send_type "() -> [::String, ::Float, ::Float, ::Float, ::Float, ::Float]",
                     Benchmark::Tms.new, :to_a
  end

  def test_to_h
    assert_send_type "() -> { label: String, utime: Float, stime: Float, cutime: Float, cstime: Float, real: Float }",
                     Benchmark::Tms.new, :to_h
  end

  def test_constants
    assert_const_type "::String", "Benchmark::Tms::CAPTION"
    assert_const_type "::String", "Benchmark::Tms::FORMAT"
  end
end
