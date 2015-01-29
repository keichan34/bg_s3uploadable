module ActionDispatch::Routing
  class Mapper
    def bg_s3uploadable(options={})
      controller = options[:controller] || "bg_s3uploadable/signed_urls"

      scope path: "/s3", as: :s3 do
        get '/signed_url', controller: controller, action: 'show'
        get '/uploaded_image', controller: controller, action: 'uploaded_image'
        get '/uploaded_image/*key', controller: controller, action: 'uploaded_image',
          format: false, as: :uploaded_image_with_key
      end
    end
  end
end
