module BgS3uploadable
  module Uploadable
    extend ActiveSupport::Concern

    included do
      after_commit :queue_s3key_notifications
    end

    private

    def set_s3key(attachment, key)
      return if key.blank?

      fail ArgumentError, 'Invalid key' unless key =~ /\Auploads\//

      write_attribute :"#{attachment}_s3key", key

      @s3key_notifications_required ||= []
      @s3key_notifications_required << attachment

      # Clear the old attachment out while processing.
      send(:"#{attachment}=", nil)
    end

    def queue_s3key_notifications
      return if @s3key_notifications_required.blank?

      @s3key_notifications_required.each do |attachment|
        UploaderJob.perform_later self, attachment.to_s
      end

      @s3key_notifications_required = nil
    end

    module ClassMethods
      def s3_uploadable(*attachments)
        attachments.each { |e| _s3_uploadable e }
      end

      private

      def _s3_uploadable(attachment)
        define_method :"#{attachment}_s3key=" do |key|
          set_s3key attachment, key
        end

        attr_reader :"remove_#{attachment}"

        define_method :"remove_#{attachment}=" do |value|
          instance_variable_set :"@remove_#{attachment}", value
          if value == '1' or value == 1
            send(:"#{attachment}=", nil)
          end
        end
      end
    end
  end
end
