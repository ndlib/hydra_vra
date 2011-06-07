# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

#Group.create([{ :name => 'administrators', :for_cancan => true, :restricted => true }, { :name => 'coordinators', :for_cancan => true }])

Group.create([{ :name => 'archivist', :for_cancan => true, :restricted => true }, { :name => 'coordinators', :for_cancan => true }])

#admin = Group.find_by_name('administrators')
archivist = Group.find_by_name('archivist')

['dbrubak1','rjohns14', 'blakshmi'].each do |login|
  user = User.find_or_create_user_by_login(login)
  user.groups << archivist
end
