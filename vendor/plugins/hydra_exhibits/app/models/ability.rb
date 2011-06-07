class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in) 
    if user.in_group? :administrators
      can :manage, :all
      cannot :destroy, Group, :for_cancan => true
    elsif user.in_group? :coordinators
      can :manage, :all
      cannot :edit, User, :groups => { :name => 'administrators' }
      cannot :destroy, User, :groups => { :name => 'administrators' }
      cannot :manage, Group, :restricted => true
      cannot :destroy, Group
    else
      can :read, :all
    end
  end
end
