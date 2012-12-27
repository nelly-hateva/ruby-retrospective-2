class Integer
  def prime?
    2.upto(Math.sqrt(self)).all? { |number| (self % number).nonzero? }
  end

  def prime_divisors
    2.upto(abs).select { |divisor| (abs % divisor).zero? and divisor.prime?}
  end
end

class Range
  def fizzbuzz
    map do |number|
      if number % 15 == 0 then :fizzbuzz
      elsif number % 3 == 0 then :fizz
      elsif number % 5 == 0 then :buzz
      else number
      end
    end
  end
end

class Hash
  def group_values
    keys.group_by { |key| self[key] }
  end
end

class Array
  def densities
    map { |element| count element }
  end
end
