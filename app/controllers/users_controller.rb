class UsersController < ApplicationController
  
  # see vendor/plugins/resource_controller
  resource_controller :singleton
  
  create.flash { "Welcome #{@user.login}!"}

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated profile."
      redirect_to root_url
    else
      render :action => 'edit'
    end
  end
  
  protected
  def object
    @object ||= current_user
  end

end