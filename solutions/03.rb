class Expr
  attr_reader :sexpression, :environment

  def self.build(sexpression)
    new sexpression
  end

  def initialize(sexpression)
    @sexpression = sexpression
  end

  def evaluate(environment)
    if sexpression.length == 2
      Unary.build(sexpression).evaluate(environment)
    elsif sexpression.length == 3
      Binary.build(sexpression).evaluate(environment)
    end
  end

  def ==(other)
    @sexpression == other.sexpression
  end
end

class Unary < Expr
  def self.build(sexpression)
    case sexpression[0]
      when :-
        Negation.new(sexpression[1])
      when :sin
        Sine.new(sexpression[1])
      when :cos
        Cosine.new(sexpression[1])
      when :variable
        Variable.new(sexpression[1])
      when :number
        Number.new(sexpression[1])
    end
  end
end

class Number < Unary
  def initialize(number)
    @number = number
  end

  def evaluate(environment = {})
    @number
  end
end

class Variable < Unary
  def initialize(name)
    @name = name
  end

  def evaluate(environment = {})
    environment[@name]
  end
end

class Negation < Unary
  def initialize(operand)
    @operand = Expr.build(operand)
  end

  def evaluate(environment = {})
    - @operand.evaluate(environment)
  end
end

class Sine < Unary
  def initialize(operand)
    @operand = Expr.build(operand)
  end

  def evaluate(environment = {})
    Math.sin(@operand.evaluate(environment))
  end
end

class Cosine < Unary
  def initialize(operand)
    @operand = Expr.build(operand)
  end

  def evaluate(environment = {})
    Math.cos(@operand.evaluate(environment))
  end
end

class Binary < Expr
  attr_reader :operation, :left_operand, :right_operand

  def self.build(sexpression)
    case sexpression[0]
      when :+
        Addition.new(Expr.build(sexpression[1]), Expr.build(sexpression[2]))
      when :*
        Multiplication.new(Expr.build(sexpression[1]), Expr.build(sexpression[2]))
    end
  end
end

class Addition < Binary
  def initialize(left_operand, right_operand)
    @left_operand, @right_operand = left_operand, right_operand
  end

  def evaluate(environment = {})
    @left_operand.evaluate(environment) + @right_operand.evaluate(environment)
  end
end

class Multiplication < Binary
  def initialize(left_operand, right_operand)
    @left_operand, @right_operand = left_operand, right_operand
  end

  def evaluate(environment = {})
    @left_operand.evaluate(environment) * @right_operand.evaluate(environment)
  end
end
