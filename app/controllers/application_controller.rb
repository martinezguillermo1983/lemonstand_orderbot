class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

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

    private
    def require_login
      unless current_user
        redirect_to "/login"
      end
    end
end
