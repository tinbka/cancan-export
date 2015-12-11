module CanCan
  module Export
    module Rule
      
      def compile(ability, compiler)
        {
          matchAll: @match_all,
          baseBehavior: @base_behavior,
          subjects: @subjects.map(&:to_s),
          actions: ability.send(:expand_actions, @actions).map(&:to_s).uniq,
          conditions: @conditions,
          blockSource: @block && compiler.to_js(@block)
        }
      end
      
    end
  end
end