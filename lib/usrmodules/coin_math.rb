module CoinMath

  def count_digits( num )
    Math.log10( num.abs ).floor
  end

  def significant_digits( amt, n )
    amt.round(- count_digits(amt) + (n - 1).round(0))
  end

end
