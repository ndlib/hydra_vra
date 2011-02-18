require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserSessionsController do

  describe "POST 'create'" do
    it "should create user session" do
      post :create, :user_session => { :login => "archivist1", :password => "archivist1" }
      user_session = UserSession.find
      user_session.should_not be_nil
      user_session.user.should == users(:archivist1)
      response.should redirect_to('/')
    end

    it "should not create user session for invalid password" do
      post :create, :user_session => { :login => "archivist1", :password => "bogus" }
      user_session = UserSession.find
      user_session.should be_nil
      response.should be_success
      response.should render_template('new')
    end
  end
  
end