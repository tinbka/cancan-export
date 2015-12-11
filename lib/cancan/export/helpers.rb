module CanCan
  module Export
    module ControllerHelpers
      
      def gon
        super.tap do |g|
          if current_user
            g.user ||= current_user
            g.ability ||= current_ability
          end
        end
      end
      
    end
  end
end