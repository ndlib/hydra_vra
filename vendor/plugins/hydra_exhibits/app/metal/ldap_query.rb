# Allow the ldap query to run apart from the rails stack
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)
require 'rubygems'
require 'net/ldap'
require 'json'

class LdapQuery
  def self.call(env)
    if env["PATH_INFO"] =~ /^\/ldap_query/
      [200, {"Content-Type" => "application/json"}, [self.search(Rack::Request.new(env).params['term'])]]
    else
      [404, {"Content-Type" => "text/html"}, ["Not Found"]]
    end
  end

  def self.search(term)
    term.strip! if term
    return "" if term.blank?
    ldap_attributes = [LDAP_USER_ID, LDAP_LAST_NAME, LDAP_FIRST_NAME, LDAP_NICKNAME]
    ldap = Net::LDAP.new(
      :host => LDAP_HOST,
      :port => LDAP_PORT,
      :auth => {
        :method   => LDAP_ACCESS_METHOD,
        :username => LDAP_ACCESS_USER,
        :password => LDAP_ACCESS_PASSWORD
      }
    )
  
    results = ldap.search(
      :base          => LDAP_BASE,
      :attributes    => ldap_attributes,
      :filter        => Net::LDAP::Filter.eq( LDAP_USER_ID, "#{term}*" ) | Net::LDAP::Filter.eq( LDAP_AGGREGATE_NAME, "#{term}*" ),
      :return_result => true
    )
    if results
      data = []
      results.each do |entry|
        result = {}
        result['netid'] = entry[:uid][0]
        formal_nickname = entry[:ndvanityname][0]                   # edupersonnickname appears to contain the same information
        if formal_nickname && formal_nickname.split(' ').count > 1  # sometimes the formal nickname only contains the first name
          result['name'] = formal_nickname
        else
          result['name'] = "#{entry[:givenname][0]} #{entry[:sn][0]}"
        end
        data << result
      end
      return JSON.generate(data)
    else
      return ""
    end
  end
end
