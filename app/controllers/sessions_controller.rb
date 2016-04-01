class SessionsController < ApplicationController
    def new
    end

    def create
        user = User.find_by(email: params[:session][:email].downcase)
        if user && user.authenticate(params[:session][:password])
            log_in user
        attr_reader :attr_namesedirect_to "/test"
        else
            redirect_to "/test1"
            # flash[:danger] = 'Invalid email/password combination' # Not quite right!
            # render 'new'
        end
    end

    def destroy
        log_out
        redirect_to root_url
    end
end
