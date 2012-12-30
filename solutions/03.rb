
module Expr
  def self.build(sexpression)
    if sexpression.length == 2
      Unary.build sexpression[0], sexpression[1]
    else 
      Binary.build sexpression[0], sexpression[1], sexpression[2]
    end
  end
end

class Unary
  include Math

  def self.build(operation, operand)
    case operation
    when :sin then Sine.new(Expr.build operand)
    when :cos then Cosine.new(Expr.build operand)
    when :number then Number.new(operand)
    when :variable then Variable.new(operand)
    when :- then Negation.new(Expr.build operand)
    end
  end

  def ==(other)
    self.class == other.class and operand == other.operand
  end

  def exact?
    operand.exact?
  end
end

class Number < Unary
  attr_reader :operand

  def initialize(operand)
    @operand = operand
  end

  def evaluate(environment = {})
    operand
  end

  def simplify
    self
  end

  def exact?
    true
  end

  def derive(variable)
    Number.new(0)
  end
end

class Variable < Unary
  attr_reader :operand

  def initialize(operand)
    @operand = operand
  end

  def exact?
    false
  end

  def evaluate(environment = {})
    if environment.has_key?(operand)
      environment[operand]
    else
      raise "Uninitialized variable"
    end
  end

  def simplify
    self
  end

  def derive(variable)
    if variable == operand
      Number.new(1)
    else
      Number.new(0)
    end
  end
end

class Negation < Unary
  attr_reader :operand

  def initialize(operand)
    @operand = operand
  end

  def evaluate(environment = {})
    - operand.evaluate(environment)
  end

  def derive(variable)
    Negation.new(operand.derive(variable)).simplify
  end

  def simplify
    if exact?
      return Number.new evaluate
    end
    if operand == Number.new(0)
      Number.new(0)
    end
    result = (Negation.new(operand)).simplify
    if result.exact?
      (Number.new(result)).evaluate
    elsif self == result
      result
    else
      result.simplify
    end
  end
end

class Sine < Unary
  attr_reader :operand

  def initialize(operand)
    @operand = operand
  end

  def evaluate(environment = {})
    sin(operand.evaluate environment)
  end

  def derive(variable)
    Multiplication.new(operand.derive(variable), Cosine.new(operand)).simplify
  end

  def simplify
    if exact?
      return Number.new evaluate
    end
    result = (Sine.new(operand)).simplify
    if result.exact?
      (Number.new(result)).evaluate
    elsif self == result
      result
    else
      result.simplify
    end
  end
end

class Cosine < Unary
  attr_reader :operand

  def initialize(operand)
    @operand = operand
  end

  def evaluate(environment = {})
    cos(operand.evaluate environment)
  end

  def derive(variable)
    Multiplication.new(operand.derive(variable), Negation.new(Sine.new operand)).simplify
  end

  def simplify
    if exact?
      Number.new(evaluate)
    end
    result = (Cosine.new(operand)).simplify
    if result.exact?
      (Number.new(result)).evaluate
    elsif self == result
      result
    else
      result.simplify
    end
  end
end

class Binary
  def self.build(operation, left_operand, right_operand)
    case operation
    when :+ then Addition.new Expr.build(left_operand), Expr.build(right_operand)
    when :* then Multiplication.new Expr.build(left_operand), Expr.build(right_operand)
    end
  end

  def exact?
    left_operand.exact? and right_operand.exact?
  end

  def ==(other)
    self.class == other.class and left_operand == other.left_operand and right_operand == other.right_operand
  end
end

class Addition < Binary
  attr_reader :left_operand, :right_operand

  def initialize(left_operand,right_operand)
    @left_operand = left_operand
    @right_operand = right_operand
  end

  def evaluate(environment = {})
    left_operand.evaluate(environment) + right_operand.evaluate(environment)
  end

  def derive(variable)
    Addition.new(left_operand.derive(variable), right_operand.derive(variable)).simplify
  end

  def simplify
    if exact?
      Number.new(evaluate)
    end
    if left_operand == Number.new(0)
      return right_operand.simplify
    elsif right_operand == Number.new(0)
      return left_operand.simplify
    end
    result = Addition.new left_operand.simplify, right_operand.simplify
    if result.exact?
      Number.new result.evaluate
    elsif self == result
      result
    else
      result.simplify
    end
  end
end

class Multiplication < Binary
  attr_accessor :left_operand, :right_operand

  def initialize(left_operand,right_operand)
    @left_operand = left_operand
    @right_operand = right_operand
  end

  def evaluate(environment = {})
    left_operand.evaluate(environment) * right_operand.evaluate(environment)
  end

  def derive(variable)
    left_aggend = Multiplication.new(left_operand.derive(variable), right_operand)
    right_aggend = Multiplication.new(left_operand, right_operand.derive(variable))
    Addition.new(left_aggend, right_aggend).simplify
  end

  def simplify
    if exact?
      return Number.new(evaluate)
    end
    if left_operand == Number.new(0)
      return Number.new(0)
    elsif right_operand == Number.new(0)
      return Number.new(0)
    elsif left_operand == Number.new(1)
      return right_operand.simplify
    elsif right_operand == Number.new(1)
      return left_operand.simplify
    end
    result = Multiplication.new left_operand.simplify, right_operand.simplify
    if result.exact?
      Number.new result.evaluate
    elsif self == result
      result
    else
      result.simplify
    end
  end
end
