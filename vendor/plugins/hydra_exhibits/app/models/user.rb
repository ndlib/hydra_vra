require 'net/ldap'
require "#{RAILS_ROOT}/vendor/plugins/blacklight/app/models/user.rb"

class User < ActiveRecord::Base
  include Blacklight::User::Authlogic
  has_and_belongs_to_many :groups

  validates_uniqueness_of :login

  before_validation_on_create :enrich_data_from_ldap
  before_validation_on_update :purge_remaining_groups
  after_validation_on_create  :validate_netid

  named_scope :users_in_hydra_group, lambda {|*group|
    {
      :select     => 'login',
      :joins      => 'INNER JOIN `groups_users` ON `groups_users`.`user_id` = `users`.`id`
                      INNER JOIN `groups` ON `groups`.`id` = `groups_users`.`group_id`',
      :conditions => ["`group`.`is_hydra_role` = ? AND `groups_users`.`group_id` = ?", true, group.flatten.first.id]
    } unless group.flatten.first.blank?
  }

  attr_accessor :invalid_netid, :no_groups_selected

  def self.ldap_lookup(netid)
    return nil if netid.blank?
    ldap = Net::LDAP.new :host => 'directory.nd.edu',
                         :port => 389,
                         :auth => { :method   => :simple,
                                    :username => '',
                                    :password => 'anonymous'
                                  }
    results = ldap.search(
      :base          => 'o=University of Notre Dame,st=Indiana,c=US',
      :attributes    => [
                         'uid',
                         'givenname',
                         'sn',
                         'ndvanityname',
                         'ndprimaryaffiliation'
                        ],
      :filter        => Net::LDAP::Filter.eq( 'uid', netid ),
      :return_result => true
    )
    results.first
  end

  def self.type_from_affiliation(affiliation)
    case
    when affiliation == 'Faculty'
      'Faculty'
    when affiliation == 'Staff'
      'Staff'
    else
      'Student'
    end
  end

  def self.create_from_ldap(netid)
    person       = self.ldap_lookup(netid)
    account_type = self.type_from_affiliation(person[:ndprimaryaffiliation].first)
    new_user = User.new(
      :login        => person[:uid].first,
      :email        => "#{person[:uid].first}@nd.edu",
      :first_name   => person[:givenname].first,
      :last_name    => person[:sn].first,
      :nickname     => person[:ndvanityname].first,
      :account_type => account_type
    )
    new_user.save!
    new_user
  end

  def self.find_or_create_user_by_login(login)
    existing_user = User.find_by_login(login)
    existing_user ? existing_user : User.create_from_ldap(login)
  end

  def self.user_names_in_hydra_group(group)
    user_names_in_hydra_group(group).map{|user| user.login}
  end

  # Assume that all users are from ND
  def nd?
    true
  end
  alias_method :nd, :nd?

  def in_group?(group)
    RoleMapper.roles(self.login).include? group.to_s
  end

  def add_to_group(group)
    groups << group if group 
  end

  def add_to_group_by_name(group_name)
    group = Group.find_by_name(group_name)
    add_to_group group
  end

  def name
    if nickname && nickname.split(' ').count > 1
      nickname
    else
      # NOTE that origionally the first_name and last_name attributes were defined in USER_ATTRIBUTES found:
      # vendor/plugins/hydra_repository/lib/hydra/generic_user_attributes.rb
      # They have been removed as a quick workaround
      "#{self.first_name} #{self.last_name}"
    end
  end

  def name_with_login
    "#{name} (#{login})"
  end

  def require_password?
    (self.nd == false) && (self.updated_account == false)
  end

  def hydra_groups
    Group.hydra_groups_for_user(self)
  end

  def hydra_group_names
    hydra_groups.map{|group| group.name} rescue nil
  end

  private

  def enrich_data_from_ldap
    attrs = User.ldap_lookup(login)
    if attrs.nil? || attrs[:uid].first.blank?
      self.invalid_netid = true
    else
      self.login        ||= attrs[:uid].first
      self.email        ||= "#{attrs[:uid].first}@nd.edu"
      self.first_name   ||= attrs[:givenname].first
      self.last_name    ||= attrs[:sn].first
      self.nickname     ||= attrs[:ndvanityname].first
      self.account_type ||= User.type_from_affiliation(attrs[:ndprimaryaffiliation].first)
      self.email        ||= "#{login}@nd.edu"
    end
  end

  def purge_remaining_groups
    group_ids = [] if no_groups_selected
  end

  def validate_netid
    if self.invalid_netid && self.invalid_netid == true
      self.errors.add('login', 'the NetID provided is not present in LDAP')
    end
  end

end
