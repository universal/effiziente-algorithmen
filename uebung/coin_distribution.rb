class CoinDistribution
  attr_accessor :coins
  
  def initialize(*available_coins)
    self.coins = available_coins
    self.coins.sort! {|a,b| b <=> a}
  end
  
  def to_coins(amount)
    distribution = Hash.new
    self.coins.each do |coin|
      count = amount / coin
      amount -= count * coin
      distribution[coin] = count
      break if amount == 0
    end
    distribution
  end
end