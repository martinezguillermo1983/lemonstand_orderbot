class ApplicationController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods

    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    # protect_from_forgery with: :exception
    helper :all

    private
    def authenticate_orderbot
        authenticate_or_request_with_http_token do |token, options|
            params[:client_code] = token
            OrderBotClient.exists?(client_code: token)
        end
    end
end
