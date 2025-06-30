module Erased
  class Engine < Rails::Engine
    isolate_namespace Erased
    config.eager_load_namespaces << Erased

    PRECOMPILE_ASSETS = %w[ erased.js ]

    initializer "erased.assets" do
      if Rails.application.config.respond_to?(:assets)
        Rails.application.config.assets.precompile += PRECOMPILE_ASSETS
      end
    end
  end
end
