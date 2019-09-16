# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |policy|
	policy.default_src :self, :http
  	policy.font_src    :self, :data, 'fonts.googleapis.com', 'fonts.gstatic.com'
  	policy.img_src     :self, :data, "https://s3-#{Settings.aws_s3_region}.amazonaws.com/#{Settings.aws_s3_bucket}/",
  		"https://#{Settings.aws_s3_bucket}.s3.#{Settings.aws_s3_region}.amazonaws.com/"
  	policy.object_src  :none
  	policy.script_src  :self, :unsafe_inline
  	policy.style_src   :self, :unsafe_inline, 'fonts.googleapis.com'
end

# If you are using UJS then enable automatic nonce generation
# Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
