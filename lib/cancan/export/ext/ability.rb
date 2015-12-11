module CanCan
  module Export
    module Ability
      extend ActiveSupport::Concern
      
      included do
        @@compiler = CanCan::Export::Compiler.new
      end
      
      def helper_method(*method_names)
        helper_methods.merge! method_names.map {|method_name|
          [method_name, @@compiler.to_js(method(method_name))]
        }.to_h
      end
      
      def user_as(property_name)
        @user_property = property_name
      end
      
      def helper_methods
        @helpers ||= {}
      end
      
      def to_json(options={})
        {
          rules: @rules.map {|rule|
            rule.compile(self, @@compiler)
          },
          rulesIndex: @rules_index.map {|object, indices|
            [object.to_s, indices]
          }.to_h,
          helpersSource: helper_methods,
          userProperty: @user_property
        }.to_json(options)
      end
    
    end
  end
end
