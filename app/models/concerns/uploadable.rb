module Uploadable
	extend ActiveSupport::Concern

	S3PresignedPut = Struct.new(:key, :url)

	ACL_PRIVATE = 'private'
	ACL_PUBLIC = 'public-read'
	UPLOADS_FOLDER = 'uploads'
	MAX_FILESIZE = 10.megabytes
	SIGNATURE_EXPIRATION = 3600 * 2
	REGION = Settings.aws_s3_region
	BUCKET = Settings.aws_s3_bucket
	DEFAULT_REQUEST_TYPE = :put
	BASE_URL = "https://s3-#{REGION}.amazonaws.com/#{BUCKET}"

  	module ClassMethods
  		def s3_presigned_url(filename='', acl=ACL_PUBLIC)
  			DEFAULT_REQUEST_TYPE == :put ?
  				s3_presigned_put(filename, acl) :
  				s3_presigned_post(acl)
  		end

	  	def s3_private_presigned_url
			s3_presigned_url(ACL_PRIVATE)
	  	end

	  	def s3_public_presigned_url
			s3_presigned_url(ACL_PUBLIC)
	  	end

	  	def s3_presigned_put(filename='', acl=ACL_PUBLIC)
	  		key = s3_file_key(filename)
			obj = s3_bucket.object(s3_filename(key))
			
			S3PresignedPut.new key, URI.unescape(
				obj.presigned_url(
					:put, 
					acl: acl, 
					expires_in: SIGNATURE_EXPIRATION
				)
			)
	  	end

	  	def s3_presigned_post(acl=ACL_PUBLIC)
			key = s3_file_key
			obj = s3_bucket.object(s3_filename(key))

			request = obj.presigned_post(
				acl: acl,
				success_action_status: '201',
				content_type_starts_with: '',
				content_length_range: 0..MAX_FILESIZE,
				signature_expiration: SIGNATURE_EXPIRATION.seconds.since
			)
		end

	  	def s3_put(data, acl=ACL_PUBLIC)
	  		filename = File.basename(data)
	  		config = s3_presigned_put(filename, acl)

	  		begin
	  			response = RestClient.put(config.url, data)
	  			return config.key
		  	rescue => e
		  		Bugsnag.notify e
		  		return nil
		  	end
	  	end

	  	def s3_post(data, acl=ACL_PUBLIC)
	  		config = s3_presigned_post(acl)

	  		begin
		  		response = RestClient::Request.execute(
		  			method: :post, 
		  			url: config.url, 
		  			payload: config.fields.merge({ file: data })
		  		)

		  		xml_response = Nokogiri::XML(response)
		  		key = xml_response.root.xpath('Key').text
		  		filename = key.split('/').last

		  		return filename
		  	rescue => e
		  		Bugsnag.notify e
		  		return nil
		  	end
	  	end

		def s3_resource_key
			name.underscore.downcase.pluralize
		end

		def s3_file_key(filename=nil)
			uuid = SecureRandom.uuid.underscore

			filename ? 
				[uuid, filename].reject(&:blank?).join('_') : 
				"#{uuid}_${filename}"
		end

		def s3_filename(key)
			"#{UPLOADS_FOLDER}/#{s3_resource_key}/#{key}"
		end

		def s3_file_url(key)
			URI.encode("#{BASE_URL}/#{s3_filename(key)}")
		end

		def original_filename(key)
			uuid, sep, filename = key.rpartition('_')
			filename
		end

  		def s3_bucket
			s3 = Aws::S3::Resource.new(
				access_key_id: Rails.application.credentials.aws_access_key_id,
				secret_access_key: Rails.application.credentials.aws_secret_access_key,
				region: Settings.aws_s3_region
			)
			s3.bucket(Settings.aws_s3_bucket)
  		end

		private
			def mount_field(field, type: nil, accepted_formats: [])
		  		define_method "#{field}_key" do
					send(field)
		  		end

		  		define_method "#{field}_key=" do |val|
					send("#{field}=", val)
		  		end

		  		define_method "#{field}_original_filename" do
					key = send(field)
					self.class.original_filename(key)
		  		end

		  		define_method "#{field}_url" do
					key = send(field)
					return nil unless key.present?

					self.class.s3_file_url(key)
		  		end
			end

			def mount_array(field)
		  		define_method "#{field}_keys" do
					send(field).join(',')
		  		end

		  		define_method "#{field}_keys=" do |val|
					send("#{field}=", val.split(','))
		  		end

		  		define_method "#{field}_original_filenames" do
					keys = send(field)
					keys.compact.map { |key| self.class.original_filename(key) }
		  		end

		  		define_method "#{field}_urls" do |version = ''|
					keys = send(field)
					return [] unless keys.present?

					keys.compact.map { |key| self.class.s3_file_url(key) }
		  		end
			end
  	end
end