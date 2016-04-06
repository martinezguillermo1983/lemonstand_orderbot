class RootController < ApplicationController
    before_filter :require_login
    def show
    end
end
