=begin
class UserSessionsController < ApplicationController

  def create
    #logger.debug("Params for user_session: #{params.inspect}")
    #logger.debug("previous page: #{params[:user_session][:redirect_url]}")
    @user_session = UserSession.new(params[:user_session])
    puts "\n--------------\ncreated user session: \n#{@user_session} \n-------------\n"
    if @user_session.save
      flash[:notice] = "Welcome #{@user_session.login}!"
      #redirect_to root_path
      redirect_to(params[:user_session][:redirect_url]) 
    else
      flash.now[:error] =  "Couldn't locate a user with those credentials"
      render :action => :new
    end
  end
  
end
=end

require 'casclient'
require 'casclient/frameworks/rails/filter'

class UserSessionsController < ApplicationController
  before_filter :link_back
  before_filter ::CASClient::Frameworks::Rails::Filter, :only => :new unless RAILS_ENV == "test"

  def new
    logger.debug("previous page: #{session['target_path']}")
    @user_session = UserSession.new
    session['target_path'] ? redirect_to( session['target_path'] ) : redirect_to( root_path )
    flash[:notice] = "Welcome #{current_user.login}!"
  end

  def destroy
    current_user_session.destroy rescue nil
    reset_session
  end

  def link_back
    session['target_path'] = request.referer
  end

end
