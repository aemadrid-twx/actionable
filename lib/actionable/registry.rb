# frozen_string_literal: true

module Actionable
  # A map of every named action class, keyed by class name (decision D11).
  # {Action} registers each subclass through its +inherited+ hook; anonymous
  # subclasses (which have no name) are skipped. Callers treat it as read-only,
  # but it is not frozen: {#register} is public (the hook calls it), and
  # nothing removes an entry. Used for discovery
  # and tooling — e.g. sweeping all actions to generate RBS.
  class Registry
    def initialize
      @map = {}
    end

    # Register an action class under its name, replacing any class already
    # registered by that name. No-op for anonymous classes. Called by
    # +Action.inherited+; public for that reason, not for callers.
    #
    # @param klass [Class] the action subclass
    # @return [self]
    def register(klass)
      name = klass.name
      @map[name] = klass unless name.nil?
      self
    end

    # @param name [String, Symbol] an action class name
    # @return [Class, nil] the registered class, or +nil+
    def [](name)
      @map[name.to_s]
    end

    # @yieldparam name [String]
    # @yieldparam klass [Class]
    # @return [Enumerator, self]
    def each(&)
      return @map.each unless block_given?

      @map.each(&)
      self
    end

    # @return [Array<String>] the registered class names
    def keys
      @map.keys
    end

    # @return [Array<Class>] the registered classes
    def values
      @map.values
    end

    # @return [Integer] the number of registered classes
    def size
      @map.size
    end

    # @return [Boolean] whether nothing is registered
    def empty?
      @map.empty?
    end
  end

  # @return [Registry] the process-wide action registry
  def self.registry
    @registry ||= Registry.new
  end
end
