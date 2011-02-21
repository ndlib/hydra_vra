require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserSessionsController do

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

=begin
it "should not create user session for invalid password" do
      post :create, :user_session => { :login => "archivist1", :password => "bogus" }
      user_session = UserSession.find
      user_session.should be_nil
      response.should be_success
      response.should render_template('new')
    end
=end
  end
  
end