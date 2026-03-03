require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList["test/**/test_*.rb"]
end

task :default => :test

namespace :rbs do
  Rake::TestTask.new(:test) do |t|
    t.libs << "test_sig"
    t.test_files = FileList["test_sig/test_*.rb"]
    t.warning = true
  end

  task :annotate do
    require "tmpdir"

    Dir.mktmpdir do |tmpdir|
      sh("rdoc --ri --output #{tmpdir}/doc --root=. lib")
      sh("rbs annotate --no-system --no-gems --no-site --no-home -d #{tmpdir}/doc sig")
    end
  end
end
