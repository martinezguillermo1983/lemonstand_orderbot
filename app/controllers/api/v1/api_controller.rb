class Api::V1::ApiController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery :null_session
  rescue_from StandardError, with: :render_unknown_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_error
  rescue_from ActionController::BadRequest, with: :render_bad_request_error


    def render_unknown_error(error)
      render(json: error.message, status: 500)
    end

    def render_not_found_error(error)
      render(json: error.message, status: 404)
    end

    def render_bad_request_error(error)
      render(json: error.message, status: 400)
    end

    private
    def authenticate_orderbot
        authenticate_or_request_with_http_token do |token, options|
            params[:client_code] = token
            OrderBotClient.exists?(client_code: token)
        end
    end

    private
    def authenticate_lemonstand
        authenticate_or_request_with_http_token do |token, options|
            params[:client_code] = token
            LemonStandClient.exists?(client_code: token)
        end
    end
end