#Querying belongs_to associations! 

class Person < ActiveRecord::Base
  belongs_to :role
end

class Role < ActiveRecord::Base
  has_many :people
end

__________________________________________________________________________________________________________

Person.all

#It returns the following
#

id  name  role_id
1 wendell 1
2 christie 1
3 eve 2


_________________________________________________________________________________________________________

#Find all people who belong to a billable role

Person.all.select { |person| person.role.billable? }
#This works but is not efficient
#for each person, we're making a request to the roles table
#Our application is retrieving more data from the database than it actually needs
#We're building lots of memory-hungry ActiveRecord Role objects that we don't need.


_______________________________________________________________________________________________________

#Gluing tables together with the joins method

Person.all.joins(:role)

#Filtering with the where method
#

Person.all.joins(:role).where(roles: {billable: true} )

_______________________________________________________________________________________________________

#So far this is good and works but it feels like the the billable: true should really be on the role model

class Role < ActiveRecord::Base
  def self.billable
    where(billable: true)
  end
end

#So now we can then say:

Person.joins(:role).merge(Role.billable)

#But because we need to still use the joins as we need attributes from the role table, we can then do this:
#
class Role < ActiveRecord::Base
  def self.billable
    joins(:role).merge(Role.billable)
  end
end

Person.billable
