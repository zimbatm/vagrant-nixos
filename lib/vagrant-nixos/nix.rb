#################################################
# Naughty extending of builtins.
# Add to_nix functions to convert ruby2nix (ish).
#################################################

module Nix
  INDENT_STRING="  "

  def self.method_missing(m, *args, &block)
    NixBuilder.new(nil, m.to_sym, *args)
  end

  class NixBuilder

    attr_accessor :exprs
    attr_accessor :parent

    def initialize(parent, expr, *args)
      @parent = parent
      @exprs  = args.inject([expr]){|exs, e| exs << e}
    end

    def method_missing(m, *args, &block)
      NixBuilder.new(self, m.to_sym, *args)
    end

    def to_nix(indent = 0)
      s = ""
      s << "(" if @exprs[0] == :import
      if @parent
        s = @parent.to_nix << "."
      end
      s << @exprs.map{|e| e.to_nix}.join(" ")
      s << ")" if @exprs[0] == :import
      s
    end
  end
end

class Symbol
  def to_nix(indent = 0)
    to_s
  end
end

class NilClass
  def to_nix(indent = 0)
    "null"
  end
end

class Hash
  def to_nix(indent = 0)
    "{\n" +
    sort {|a, b| a[0].to_s <=> b[0].to_s}.map do |key, value|
      raise "Key must be a Symbol, not #{key.class}" unless key.is_a?(Symbol)
      Nix::INDENT_STRING * (indent + 1)+ key.to_nix +
      " = " + value.to_nix(indent + 1) + ";"
    end.join("\n") + "\n" +
    Nix::INDENT_STRING * indent + "}"
  end
end

class Array
  def to_nix(indent = 0)
    "[ " + map(&:to_nix).join(" ") + " ]"
  end
end

class String
  def to_nix(indent = 0)
    return self if self.slice(0,2) == "./"
    return %{''#{self}''} if self =~ /\n/
    %{"#{self}"}
  end
end

class Integer
  def to_nix(indent = 0)
    to_s
  end
end

class TrueClass
  def to_nix(indent = 0)
    to_s
  end
end

class FalseClass
  def to_nix(indent = 0)
    to_s
  end
end
