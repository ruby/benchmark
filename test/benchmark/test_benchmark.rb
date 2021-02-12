# frozen_string_literal: true
require 'test/unit'
require 'benchmark'

class TestBenchmark < Test::Unit::TestCase

  # Call `report` 3 times with labels, then return an array of 2 statistics, total and average,
  # for inclusion in the output.
  BENCH_FOR_TIMES_UPTO = lambda do |x|
    n = 1000
    tf = x.report("for:")   { for _ in 1..n; '1'; end }
    tt = x.report("times:") { n.times do   ; '1'; end }
    tu = x.report("upto:")  { 1.upto(n) do ; '1'; end }
    [tf+tt+tu, (tf+tt+tu)/3]
  end

  # Call `report` 3 times without labels and return last Benchmark::Tms returned by `report`.
  # The fact that the value returned is a Tms and not an array of Tms instances will be interpreted
  # by the `bm` method to indicate that this is *not* something to be added to the report items.
  BENCH_FOR_TIMES_UPTO_NO_LABEL = lambda do |x|
    n = 1000
    x.report { for _ in 1..n; '1'; end }
    x.report { n.times do   ; '1'; end }
    x.report { 1.upto(n) do ; '1'; end }
  end

  # Sample labels for the benchmarking output (will appear as, e.g. "first  --time--   --time--   --time-- (  --time--)")
  def labels
    %w[first second third]
  end

  # Provides a benchmark method that can be called with or without a block.
  # The `type` parameter will be used by `send` to call the appropriate method (e.g. `bm`)
  # If called without a block, then `report` will be called once for each label in the array of labels
  # returned by the `labels` method.
  def bench(type = :bm, *args, &block)
    if block
      Benchmark.send(type, *args, &block)
    else
      Benchmark.send(type, *args) do |x|
        labels.each { |label|
          x.report(label) {}
        }
      end
    end
  end

  # Captures stdout of the benchmark report from stdout into a string, and replaces the measurements
  # with a generic string so that comparisons will not fail due to different timings.
  #
  # If block is nil then the labels in the array returned by the `labels` method will be used for empty tests.
  def capture_bench_output(type, *args, &block)
    capture_output { bench(type, *args, &block) }.first.gsub(/[ \-]\d\.\d{6}/, ' --time--')
  end

  # Tests that `to_s` and `format` output nicely in the expected formats.
  def test_tms_outputs_nicely
    assert_equal("  0.000000   0.000000   0.000000 (  0.000000)\n", Benchmark::Tms.new.to_s)
    assert_equal("  1.000000   2.000000  10.000000 (  5.000000)\n", Benchmark::Tms.new(1,2,3,4,5).to_s)
    assert_equal("1.000000 2.000000 3.000000 4.000000 10.000000 (5.000000) label",
                 Benchmark::Tms.new(1,2,3,4,5,'label').format('%u %y %U %Y %t %r %n'))
    assert_equal("1.000000 2.000", Benchmark::Tms.new(1).format('%u %.3f', 2))
    assert_equal("100.000000 150.000000 250.000000 (200.000000)\n",
                 Benchmark::Tms.new(100, 150, 0, 0, 200).to_s)
  end

  # Test that Tms#format will not modify the format string parameter passed into it
  def test_tms_wont_modify_the_format_String_given
    format = "format %u"
    Benchmark::Tms.new.format(format)
    assert_equal("format %u", format)
  end

  # Expected output when an array of 2 numbers (total and avg) is returned from the block being measured,
  # and the labels '>total:' and '>avg:' are specified:
  BENCHMARK_OUTPUT_WITH_TOTAL_AVG = <<BENCH
              user     system      total        real
for:      --time--   --time--   --time-- (  --time--)
times:    --time--   --time--   --time-- (  --time--)
upto:     --time--   --time--   --time-- (  --time--)
>total:   --time--   --time--   --time-- (  --time--)
>avg:     --time--   --time--   --time-- (  --time--)
BENCH

  # Verifies that there is no vertical space output where captions (headings) would normally be,
  # if no caption has been specified.
  def test_benchmark_does_not_print_any_space_if_the_given_caption_is_empty
    assert_equal(<<-BENCH, capture_bench_output(:benchmark))
first  --time--   --time--   --time-- (  --time--)
second  --time--   --time--   --time-- (  --time--)
third  --time--   --time--   --time-- (  --time--)
BENCH
  end

  # Tests the `benchmark` method's ability to take an array of values returned by the measured block
  # and display them, using the labels passed as parameters at the end of `benchmark`'s parameter list.'
  def test_benchmark_makes_extra_calculations_with_an_Array_at_the_end_of_the_benchmark_and_show_the_result
    assert_equal(BENCHMARK_OUTPUT_WITH_TOTAL_AVG,
      capture_bench_output(:benchmark,
        Benchmark::CAPTION, 7,
        Benchmark::FORMAT, ">total:", ">avg:",
        &BENCH_FOR_TIMES_UPTO))
  end

  # Tests `bm` and `bmbm` methods to verify that:
  #
  # 1) the returned object is an array whose size is equal to the size of the specified array of labels
  # 2) each element of that array is an instance of Benchmark::Tms
  # 3) the label property of the Tms instance is equal to the original label passed
  #    (which came from the array returned by the `labels` method)
  def test_bm_returns_an_Array_of_the_times_with_the_labels
    [:bm, :bmbm].each do |meth|
      capture_output do
        results = bench(meth)
        assert_instance_of(Array, results)
        assert_equal(labels.size, results.size)
        results.zip(labels).each { |tms, label|
          assert_instance_of(Benchmark::Tms, tms)
          assert_equal(label, tms.label)
        }
      end
    end
  end

  # Verifies that overriding the label width results in correct horizontal spacing for caption and row values
  def test_bm_correctly_output_when_the_label_width_is_given
    assert_equal(<<-BENCH, capture_bench_output(:bm, 6))
             user     system      total        real
first    --time--   --time--   --time-- (  --time--)
second   --time--   --time--   --time-- (  --time--)
third    --time--   --time--   --time-- (  --time--)
BENCH
  end

  # Verifies that the absence of a label results in correct horizontal spacing
  def test_bm_correctly_output_when_no_label_is_given
    assert_equal(<<-BENCH, capture_bench_output(:bm, &BENCH_FOR_TIMES_UPTO_NO_LABEL))
       user     system      total        real
   --time--   --time--   --time-- (  --time--)
   --time--   --time--   --time-- (  --time--)
   --time--   --time--   --time-- (  --time--)
BENCH
  end

  # Verify that bm can add line items after the benchmark report lines, as long as the
  # labels are provided to the `bm` call, and the values are returned by the measured block
  # in the form of an array.
  def test_bm_can_make_extra_calcultations_with_an_array_at_the_end_of_the_benchmark
    assert_equal(BENCHMARK_OUTPUT_WITH_TOTAL_AVG,
      capture_bench_output(:bm, 7, ">total:", ">avg:",
        &BENCH_FOR_TIMES_UPTO))
  end

  # Expected output of `bmbm` when no block is provided and the array of labels returned by the `labels` method is used.
  BMBM_OUTPUT = <<BENCH
Rehearsal ------------------------------------------
first    --time--   --time--   --time-- (  --time--)
second   --time--   --time--   --time-- (  --time--)
third    --time--   --time--   --time-- (  --time--)
--------------------------------- total: --time--sec

             user     system      total        real
first    --time--   --time--   --time-- (  --time--)
second   --time--   --time--   --time-- (  --time--)
third    --time--   --time--   --time-- (  --time--)
BENCH

  # `bmbm`, unlike `bm`, will properly align all output lines, since it
  # can compute the maximum label width before printing any of them.
  # This test verifies that this works when the length is _not_ specified,
  # and therefore defaults to 0.
  def test_bmbm_correctly_guesses_the_label_width_even_when_not_given
    assert_equal(BMBM_OUTPUT, capture_bench_output(:bmbm))
  end

  # `bmbm`, unlike `bm`, will properly align all output lines, since it
  # can compute the maximum label width before printing any of them.
  # This test verifies that specifying the correct maximum label width produces the
  # same output as not specifying it at all.
  def test_bmbm_correctly_output_when_the_label_width_is_given__bmbm_ignore_it__but_it_is_a_frequent_mistake
    assert_equal(BMBM_OUTPUT, capture_bench_output(:bmbm, 6))
  end

  # `bmbm`, unlike `bm`, will properly align all output lines, since it
  # can compute the maximum label width before printing any of them.
  # This test verifies that specifying the maximum label width *that is too small*
  # still produces the correctly aligned output.
  def test_bmbm_correctly_output_when_the_specified_label_width_is_too_small
    assert_equal(BMBM_OUTPUT, capture_bench_output(:bmbm, 1))
  end

  # Verifies that it is ok to specify a report title that is not a string as long as its `to_s` returns a string
  def test_report_item_shows_the_title__even_if_not_a_string
    assert_operator(capture_bench_output(:bm) { |x| x.report(:title) {} }, :include?, 'title')
    assert_operator(capture_bench_output(:bmbm) { |x| x.report(:title) {} }, :include?, 'title')
  end

  # Verifies that `add!`ing a Tms updates the `real` property
  def test_bugs_ruby_dev_40906_can_add_in_place_the_time_of_execution_of_the_block_given
    t = Benchmark::Tms.new
    assert_equal(0, t.real)
    t.add! { sleep 0.1 }
    assert_not_equal(0, t.real)
  end

  # Verifies that the real time measured from a sleep exceeds that sleep time, proving that the real time measured
  # is taking the sleep time into account.
  def test_realtime_output
    sleeptime = 1.0
    realtime = Benchmark.realtime { sleep sleeptime }
    assert_operator sleeptime, :<, realtime
  end

  # Test that `to_h` returns a hash with the expected data.
  def test_tms_to_h
    tms = Benchmark::Tms.new(1.1, 2.2, 3.3, 4.4, 5.5, 'my label')
    expected_hash = {
      utime: 1.1, stime: 2.2, cutime: 3.3, cstime: 4.4, real: 5.5, label: 'my label'
    }
    assert_equal(expected_hash, tms.to_h)
  end
end
