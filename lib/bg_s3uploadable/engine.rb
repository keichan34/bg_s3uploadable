module BgS3uploadable
  class Engine < ::Rails::Engine
    isolate_namespace BgS3uploadable

    initializer "bg_s3uploadable.activerecord_ext" do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send :include, Uploadable
      end
    end
  end
end
