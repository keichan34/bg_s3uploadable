BgS3uploadable::Engine.routes.draw do
  get '/signed_url' => 'signed_urls#show'
  get '/uploaded_image' => 'signed_urls#uploaded_image'
  get '/uploaded_image/*key' => 'signed_urls#uploaded_image',
    format: false, as: :uploaded_image_with_key
end
