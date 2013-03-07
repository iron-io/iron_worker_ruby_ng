module IronWorkerNG
  VERSION = '0.15.2'

  def self.version
    VERSION
  end

  def self.full_version
    'iron_worker_ruby_ng-' + IronWorkerNG.version + ' (iron_core_ruby-' + IronCore.version + ')'
  end
end
