require 'rubygems'

module IronWorkerNG
  class SimpleGem
    include Comparable

    def self.find(name, version = nil)
      gems = []

      version = version.split(',') unless version.nil?

      specs = Gem::Specification.find_all_by_name(name, version)
      specs.each do |spec|
        gems << IronWorkerNG::SimpleGem.new(spec)
      end

      gems
    end

    def initialize(spec)
      @spec = spec
    end

    def name
      @spec.name
    end

    def version
      @spec.version
    end

    def native?
      @spec.extensions.length != 0
    end

    def path
      @spec.full_gem_path
    end

    def deps(recursive = false)
      gems = []

      @spec.dependencies.each do |dep|
        next if dep.type != :runtime
        gems << IronWorkerNG::SimpleGem.find(dep.name, dep.requirement.to_s).sort[-1]
      end

      if recursive
        full_gems = []

        gems.each do |gem|
         full_gems += gem.deps
         full_gems << gem
        end

        gems = full_gems.uniq { |gem| gem.to_s }
      end

      gems
    end

    def to_s
      "#{name}-#{version.to_s}"
    end

    def <=>(other)
      name == other.name ? version <=> other.version : name <=> other.name
    end
  end
end
