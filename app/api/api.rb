class API < Grape::API
  include BaseHelpers

  format :json
  default_format :json

  before do
    API.logger.debug params.except(*Rails.application.config.filter_parameters)

    header['Access-Control-Allow-Origin'] = '*'
    header['Access-Control-Request-Method'] = '*'
    header['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  after_validation do
    status RESPONSE_CODES[:ok]
    set_locale
  end

  rescue_from Grape::Exceptions::ValidationErrors do |e|
    render_error(RESPONSE_CODES[:bad_request], e.message)
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render_error(RESPONSE_CODES[:not_found], I18n.t("errors.#{e.model.to_s.downcase}.not_found"))
  end

  rescue_from StandardError do |e|
    API.logger.error e
    Bugsnag.notify(e)
    render_error(RESPONSE_CODES[:internal_server_error], 'RuntimeError', e.message)
  end

  mount V1::Main
end