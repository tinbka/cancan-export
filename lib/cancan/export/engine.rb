module CanCan
  module Export
    class Engine < ::Rails::Engine
      initializer 'cancan.export' do |app|
        app.config.assets.paths << root.join('assets', 'javascripts').to_s
      end
    end
  end
end
