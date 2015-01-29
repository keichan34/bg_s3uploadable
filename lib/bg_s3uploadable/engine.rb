require "bg_s3uploadable/rails/routes"

module BgS3uploadable
  class Engine < ::Rails::Engine
    engine_name "bg_s3uploadable"

    initializer "bg_s3uploadable.activerecord_ext" do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send :include, Uploadable
      end
    end
  end
end
