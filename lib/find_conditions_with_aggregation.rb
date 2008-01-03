module FindConditionsWithAggregation

  def self.included(mod)
    mod.extend ClassMethods
    mod.class_eval do
      class << self
        alias_method_chain :sanitize_sql_hash_for_conditions, :aggregation_support
        alias_method_chain :all_attributes_exists?, :aggregation_support
      end
    end
  end
  
  module ClassMethods
    
    def aggregate_mapping(reflection)
      mapping = reflection.options[:mapping] || [reflection.name, reflection.name]
      mapping.first.is_a?(Array) ? mapping : [mapping]
    end
    
    def sanitize_sql_hash_for_conditions_with_aggregation_support(attrs)
      expanded_attrs = {}
      attrs.each do |attr, value|
        unless (aggregation = reflect_on_aggregation(attr.to_sym)).nil?
          mapping = aggregate_mapping(aggregation)
          mapping.each do |field_attr, aggregate_attr|
            if mapping.size == 1 && !value.respond_to?(aggregate_attr)
              expanded_attrs[field_attr] = value
            else
              expanded_attrs[field_attr] = value.send(aggregate_attr)
            end
          end
        else
          expanded_attrs[attr] = value
        end
      end
      sanitize_sql_hash_for_conditions_without_aggregation_support(expanded_attrs)
    end
    
    def all_attributes_exists_with_aggregation_support?(attribute_names)
      expanded_attribute_names = []
      attribute_names.each do |attribute_name|
        unless (aggregation = reflect_on_aggregation(attribute_name.to_sym)).nil?
          aggregate_mapping(aggregation).each do |field_attr, aggregate_attr|
            expanded_attribute_names << field_attr
          end
        else
          expanded_attribute_names << attribute_name
        end
      end
      all_attributes_exists_without_aggregation_support?(expanded_attribute_names)
    end
    
  end

end

ActiveRecord::Base.send :include, FindConditionsWithAggregation