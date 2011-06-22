require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserSessionsController do

=begin
    before(:each) do
    activate_authlogic
    @user = mock({ :login => "dane", :password => "my-password", :redirect_url=>"http://localhost:3000/" })
    @user_session=mock("user session")
  end

  describe "POST 'create'" do
    it "should create user session" do
     UserSession.expects(:new).with(:user_session =>{:login => "dane", :password => "my-password", :redirect_url=>"http://localhost:3000/" }).returns(@user)
     @user_session.expects(:save).returns(true)
      logger.debug("User session is #{@user_session.inspect}")      
      post :create, :user => @user
      response.should redirect_to('http://localhost:3000/')

    end


it "should not create user session for invalid password" do
      post :create, :user_session => { :login => "archivist1", :password => "bogus" }
      user_session = UserSession.find
      user_session.should be_nil
      response.should be_success
      response.should render_template('new')
    end
=end
  #end

  before(:each) do
    @user = mock("User")
    @user.stubs(:can_be_superuser?).returns true
    @user2 = mock("User")
    @user2.stubs(:can_be_superuser?).returns false
  end

  it "should allow for toggling on and off session[:superuser_mode]" do
    controller.stubs(:current_user).returns(@user)
    request.env["HTTP_REFERER"] = ""
    get :superuser
    session[:superuser_mode].should be_true
    get :superuser
    session[:superuser_mode].should be_nil
  end

  it "should not allow superuser_mode to be set in session if current_user is not a superuser" do
    controller.stubs(:current_user).returns(@user2)
    request.env["HTTP_REFERER"] = ""
    get :superuser
    session[:superuser_mode].should be_nil
  end

  it "should redirect to the referer" do
    controller.stubs(:current_user).returns(@user)
    request.env["HTTP_REFERER"] = file_assets_path
    get :superuser
    response.should redirect_to(file_assets_path)
  end
  
end