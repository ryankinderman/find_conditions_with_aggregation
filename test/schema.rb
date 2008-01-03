ActiveRecord::Schema.define(:version => 0) do
  create_table :customers, :force => true do |t|
    t.string  :name
    t.string  :address_street
    t.string  :address_city
    t.string  :address_country
    t.decimal :balance
    t.decimal :amount
  end
end
