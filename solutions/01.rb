class Integer

  def prime?
    possible = (2..self-1)
    
    possible.each do |d|
      return false if self % d == 0
    end
    
    true
  end

  def prime_divisors
    num = self.abs
    return [num] if num.prime?
    result = []
    possible = (2..num-1)

    possible.each do |d|
      result << d if d.prime? and num % d == 0
    end

    return result
  end

end


class Range

  def fizzbuzz
    result = []

    self.each do |number|
      if number % 3 == 0 && number % 5 == 0
        result << :fizzbuzz
      elsif number % 3 == 0 
        result << :fizz
      elsif number % 5 == 0 
        result << :buzz
      else 
        result << number
      end
    end

    result
  end

end

class Hash

  def group_values
    result = Hash.new { |h,k| h[k] = (self.select { |key,value| value == k }).keys}

    self.each_value { |value| result[value]}

    result
  end

end

class Array

  def densities
    result = []

    self.each { |elem| result << self.count(elem) }

    result
  end

end
