module CanCan
  module Export
    module ControllerHelpers
      
      def gon
        super.tap do |g|
          if current_user
            g.user ||= current_user
            g.ability ||= ::Ability.new(g.user)
          end
        end
      end
      
    end
  end
end