module BgS3uploadable
  class SignedUrlsController < ApplicationController
    def show
      policy = s3_upload_policy_document

      render json: {
        policy: policy,
        signature: s3_upload_signature(policy),
        key: "uploads/#{SecureRandom.uuid}/#{doc_params[:title]}",
        success_action_redirect: "/",
        upload_endpoint: "https://#{s3_bucket}.s3.amazonaws.com",
        :AWSAccessKeyID => ENV['AWS_ACCESS_KEY_ID'],
      }
    end

    def uploaded_image
      unless params[:key] =~ /\Auploads\//
        render json: { error: 'Access denied' }, status: 403
        return
      end

      s3 = AWS::S3.new
      bucket = s3.buckets[s3_bucket]
      obj = bucket.objects[params[:key]]

      presign = AWS::S3::PresignV4.new obj

      redirect_to presign.presign(:get, expires: 5.minutes.from_now.to_i, secure: true).to_s
    end

    protected

    def s3uploadable_controller?
      true
    end

    # The bucket this controller will pre-sign uploads to. Defaults to
    # ENV["S3_BUCKET"].
    def s3_bucket
      ENV["S3_BUCKET"]
    end

    private

    # generate the policy document that amazon is expecting.
    def s3_upload_policy_document
      Base64.strict_encode64(
        {
          expiration: 30.minutes.from_now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
          conditions: [
            { bucket: s3_bucket },
            { acl: 'private' },
            ["starts-with", "$key", "uploads/"],
            { success_action_status: '201' },
            { :'x-amz-server-side-encryption' => 'AES256' }
          ]
        }.to_json
      ).gsub(/\n|\r/, '')
    end

    # sign our request by Base64 encoding the policy document.
    def s3_upload_signature(policy)
      Base64.strict_encode64(
        OpenSSL::HMAC.digest(
          OpenSSL::Digest::SHA1.new,
          ENV['AWS_SECRET_ACCESS_KEY'],
          policy
        )
      ).gsub(/\n/, '')
    end

    def doc_params
      params.require(:doc).permit :title, :size
    end
  end
end
