require 'puppet_x'
require 'singleton'

module PuppetX::PowerCLI
  # Helper class for Caching Instances
  class CachedInstances
    include Singleton
    attr_accessor :cache

    def initialize
      @cache = {}
    end
  end
end
