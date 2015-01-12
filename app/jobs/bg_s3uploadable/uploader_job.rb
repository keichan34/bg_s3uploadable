module BgS3uploadable
  class UploaderJob < ::ActiveJob::Base
    def perform(record, attachment)
      key = record.send :"#{attachment}_s3key"
      return if key.blank?

      f = Tempfile.new(SecureRandom.uuid, encoding: 'binary')

      s3 = AWS::S3.new
      bucket = s3.buckets[ENV['S3_BUCKET']]
      obj = bucket.objects[key]

      unless obj.exists?
        # This file has already been auto-deleted. There's nothing we can do
        # anymore.
        record.class.transaction do
          record.send(:write_attribute, :"#{attachment}_s3key", nil)
          record.save validate: false
        end
        return
      end

      obj.read do |chunk|
        f.write chunk
      end
      f.flush

      record.class.transaction do
        record.send(:"#{attachment}=", f)
        record.send(:write_attribute, :"#{attachment}_s3key", nil)

        record.save validate: false
      end
    ensure
      f.close
      f.unlink
    end
  end
end
