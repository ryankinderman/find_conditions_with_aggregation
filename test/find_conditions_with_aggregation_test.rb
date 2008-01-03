require File.join(File.dirname(__FILE__), 'abstract_unit')
require File.join(File.dirname(__FILE__), 'fixtures/customer')

class FindConditionsWithAggregationTest < Test::Unit::TestCase
  fixtures :customers

  def test_exists_with_aggregate_having_three_mappings
    existing_address = customers(:david).address
    assert Customer.exists?(:address => existing_address)
  end
  
  def test_exists_with_aggregate_having_three_mappings_with_one_difference
    existing_address = customers(:david).address
    assert !Customer.exists?(:address => 
      Address.new(existing_address.street, existing_address.city, existing_address.country + "1"))
    assert !Customer.exists?(:address => 
      Address.new(existing_address.street, existing_address.city + "1", existing_address.country))
    assert !Customer.exists?(:address => 
      Address.new(existing_address.street + "1", existing_address.city, existing_address.country))
  end

  def test_find_on_hash_conditions_with_explicit_table_name_and_aggregate
    david = customers(:david)
    begin
      assert Customer.find(david.id, :conditions => { 'customers.name' => david.name, :address => david.address })
      assert_raises(ActiveRecord::RecordNotFound) { 
        Customer.find(david.id, :conditions => { 'customers.name' => david.name + "1", :address => david.address }) 
      }
    rescue ActiveRecord::StatementInvalid => e
      raise StandardError, 
        "This test is expected to fail on Rails revisions earlier than 7943 because the " + \
        "feature being tested was not present prior to that revision.\n\n" + \
        "Details:\n" + \
        "#{e.class.name}: #{e.message}\n\n" + \
        e.backtrace.join("\n")
    end
  end

  def test_hash_condition_find_with_aggregate_having_one_mapping
    balance = customers(:david).balance
    assert_kind_of Money, balance
    found_customer = Customer.find(:first, :conditions => {:balance => balance})
    assert_equal customers(:david), found_customer
  end

  def test_hash_condition_find_with_aggregate_attribute_having_same_name_as_field_and_key_value_being_aggregate
    amount = customers(:david).amount
    assert_kind_of Money, amount
    found_customer = Customer.find(:first, :conditions => {:amount => amount})
    assert_equal customers(:david), found_customer    
  end

  def test_hash_condition_find_with_aggregate_having_one_mapping_and_key_value_being_attribute_value
    balance = customers(:david).balance
    assert_kind_of Money, balance
    found_customer = Customer.find(:first, :conditions => {:balance => balance.amount})
    assert_equal customers(:david), found_customer    
  end

  def test_hash_condition_find_with_aggregate_attribute_having_same_name_as_field_and_key_value_being_attribute_value
    amount = customers(:david).amount
    assert_kind_of Money, amount
    found_customer = Customer.find(:first, :conditions => {:amount => amount.amount})
    assert_equal customers(:david), found_customer    
  end
  
  def test_hash_condition_find_with_aggregate_having_three_mappings
    address = customers(:david).address
    assert_kind_of Address, address
    found_customer = Customer.find(:first, :conditions => {:address => address})
    assert_equal customers(:david), found_customer
  end
  
  def test_hash_condition_find_with_one_condition_being_aggregate_and_another_not
    address = customers(:david).address
    assert_kind_of Address, address
    found_customer = Customer.find(:first, :conditions => {:address => address, :name => customers(:david).name})
    assert_equal customers(:david), found_customer    
  end

  def test_find_by_one_attribute_that_is_an_aggregate
    address = customers(:david).address
    assert_kind_of Address, address
    found_customer = Customer.find_by_address(address)
    assert_equal customers(:david), found_customer
  end
  
  def test_find_by_one_attribute_that_is_an_aggregate_with_one_attribute_difference
    address = customers(:david).address
    assert_kind_of Address, address
    missing_address = Address.new(address.street, address.city, address.country + "1")
    assert_nil Customer.find_by_address(missing_address)
    missing_address = Address.new(address.street, address.city + "1", address.country)
    assert_nil Customer.find_by_address(missing_address)
    missing_address = Address.new(address.street + "1", address.city, address.country)
    assert_nil Customer.find_by_address(missing_address)
  end

  def test_find_by_two_attributes_that_are_both_aggregates
    balance = customers(:david).balance
    address = customers(:david).address
    assert_kind_of Money, balance
    assert_kind_of Address, address
    found_customer = Customer.find_by_balance_and_address(balance, address)
    assert_equal customers(:david), found_customer
  end

  def test_find_by_two_attributes_with_one_being_an_aggregate
    balance = customers(:david).balance
    assert_kind_of Money, balance
    found_customer = Customer.find_by_balance_and_name(balance, customers(:david).name)
    assert_equal customers(:david), found_customer
  end

  def test_find_all_by_one_attribute_that_is_an_aggregate
    balance = customers(:david).balance
    assert_kind_of Money, balance
    found_customers = Customer.find_all_by_balance(balance)
    assert_equal 1, found_customers.size
    assert_equal customers(:david), found_customers.first
  end

  def test_find_all_by_two_attributes_that_are_both_aggregates
    balance = customers(:david).balance
    address = customers(:david).address
    assert_kind_of Money, balance
    assert_kind_of Address, address
    found_customers = Customer.find_all_by_balance_and_address(balance, address)
    assert_equal 1, found_customers.size
    assert_equal customers(:david), found_customers.first
  end

  def test_find_all_by_two_attributes_with_one_being_an_aggregate
    balance = customers(:david).balance
    assert_kind_of Money, balance
    found_customers = Customer.find_all_by_balance_and_name(balance, customers(:david).name)
    assert_equal 1, found_customers.size
    assert_equal customers(:david), found_customers.first
  end

  def test_find_or_create_from_one_aggregate_attribute
    number_of_customers = Customer.count
    created_customer = Customer.find_or_create_by_balance(Money.new(123))
    assert_equal number_of_customers + 1, Customer.count
    assert_equal created_customer, Customer.find_or_create_by_balance(Money.new(123))
    assert !created_customer.new_record?
  end

  def test_find_or_create_from_two_attributes_with_one_being_an_aggregate
    number_of_customers = Customer.count
    created_customer = Customer.find_or_create_by_balance_and_name(Money.new(123), "Elizabeth")
    assert_equal number_of_customers + 1, Customer.count
    assert_equal created_customer, Customer.find_or_create_by_balance(Money.new(123), "Elizabeth")
    assert !created_customer.new_record?
  end  

  def test_find_or_create_from_one_aggregate_attribute_and_hash
    number_of_customers = Customer.count
    balance = Money.new(123)
    name = "Elizabeth"
    created_customer = Customer.find_or_create_by_balance({:balance => balance, :name => name})
    assert_equal number_of_customers + 1, Customer.count
    assert_equal created_customer, Customer.find_or_create_by_balance({:balance => balance, :name => name})
    assert !created_customer.new_record?
    assert_equal balance, created_customer.balance
    assert_equal name, created_customer.name
  end

  def test_find_or_initialize_from_one_aggregate_attribute
    new_customer = Customer.find_or_initialize_by_balance(Money.new(123))
    assert_equal 123, new_customer.balance.amount
    assert new_customer.new_record?
  end

  def test_find_or_initialize_from_one_aggregate_attribute_and_one_not
    new_customer = Customer.find_or_initialize_by_balance_and_name(Money.new(123), "Elizabeth")
    assert_equal 123, new_customer.balance.amount
    assert_equal "Elizabeth", new_customer.name
    assert new_customer.new_record?
  end

  def test_find_or_initialize_from_one_aggregate_attribute_and_hash
    balance = Money.new(123)
    name = "Elizabeth"
    new_customer = Customer.find_or_initialize_by_balance({:balance => balance, :name => name})
    assert_equal balance, new_customer.balance
    assert_equal name, new_customer.name
    assert new_customer.new_record?
  end

end