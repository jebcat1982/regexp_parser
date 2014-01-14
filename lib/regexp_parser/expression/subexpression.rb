module Regexp::Expression

  class Subexpression < Regexp::Expression::Base
    attr_accessor :expressions

    def initialize(token)
      super(token)

      @expressions = []
    end

    # Override base method to clone the expressions as well.
    def clone
      copy = super
      copy.expressions = @expressions.map {|e| e.clone }
      copy
    end

    def <<(exp)
      @expressions << exp
    end

    def insert(exp)
      @expressions.insert 0, exp
    end

    def each(&block)
      @expressions.each {|e| yield e}
    end

    def each_with_index(&block)
      @expressions.each_with_index {|e, i| yield e, i}
    end

    def first
      @expressions.first
    end

    def last
      @expressions.last
    end

    def [](index)
      @expressions[index]
    end

    def length
      @expressions.length
    end

    def to_s(format = :full)
      s = ''

      # Note: the format does not get passed down to subexpressions.
      case format
      when :base
        s << @text.dup
        s << @expressions.map{|e| e.to_s}.join unless @expressions.empty?
      else
        s << @text.dup
        s << @expressions.map{|e| e.to_s}.join unless @expressions.empty?
        s << @quantifier if quantified?
      end

      s
    end
  end

end