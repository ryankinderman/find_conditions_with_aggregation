class Customer < ActiveRecord::Base
  composed_of :address, :mapping => [ %w(address_street street), %w(address_city city), %w(address_country country) ]
  composed_of :balance, :class_name => "Money", :mapping => %w(balance amount)
  composed_of :amount, :class_name => "Money"
end

class Address
  attr_reader :street, :city, :country

  def initialize(street, city, country)
    @street, @city, @country = street, city, country
  end
  
  def close_to?(other_address)
    city == other_address.city && country == other_address.country
  end

  def ==(other)
    other.is_a?(self.class) && other.street == street && other.city == city && other.country == country
  end  
end

class Money
  attr_reader :amount
  
  def initialize(amount)
    @amount = amount
  end  
end