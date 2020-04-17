#has_many associations activerecord

class Person < ActiveRecord::Base
  belongs_to :location
  belongs_to :role
end

class Role < ActiveRecord::Base
  has_many :people
end

class Location < ActiveRecord::Base
  has_many :people
end


____________________________________________________________________________________________________________________

Role.all

id    name    billable
1   Developer     t
2   Manager       f
3   Unassigned    f

____________________________________________________________________________________________________________________

Location.all

id    name    billable
1   Boston      1
2   New York    1
3   Denver      2

____________________________________________________________________________________________________________________

People.all

id      name    role_id location_id
1     Wendell     1         1
2     Christie    1         1
3     Sandy       1         3
4     Eve         2         2

____________________________________________________________________________________________________________________

#First we want to fine all distinct locations with at least one person who belongs to a billable role.
#We can also use joins with has_many just like on belongs_to


Location.joins(:people)

        locations           |           people
   id   name     region_id  |   id  name    role_id location_id
    1   Boston    1         |    1  Wendell   1       1
    1   Boston    1         |    2  Christie  1       1
    3   Denver    2         |    3  Sandy     1       3
    2   New York  1         |    4  Eve       2       2

____________________________________________________________________________________________________________________

#The use of has_many_through


Location.joins(people: :role)

    locations          |        people                   |        roles
id  name    region_id  |  id  name  role_id location_id  |  id    name      billable
1   Boston    1        |  1  Wendell  1         1        |  1   Developer     t
1   Boston    1        |  2  Christie 1         1        |  1   Developer     t
3   Denver    2        |  3  Sandy    1         3        |  1   Developer     t
2   New York  1        |  4  Eve      2         2        |  2   Manager       f


#Then now we can filter through with .where

Location.joins(people: :role).where(roles: { billable: true })

#Which then returns something like that:
#

    locations          |        people                   |        roles
id  name    region_id  |  id  name  role_id location_id  |  id    name      billable
1   Boston    1        |  1  Wendell  1         1        |  1   Developer     t
1   Boston    1        |  2  Christie 1         1        |  1   Developer     t
3   Denver    2        |  3  Sandy    1         3        |  1   Developer     t

#But now we can notice that we see BOSTON TWICE... We can remiediate to this with the (distinct)method.
#

Location.joins(people: :role).where(roles: { billable: true}).distinct

#Which now returns something like this:
#
      locations
id   name    region_id
3   Denver      2
1   Boston      1

#We can now encapsulate our query in our object and do:
#

class location < ActiveRecord::Base
  def self.billable
    joins(people: :role).where(roles: { billable: true }).distinct
  end
end 

Location.billable


____________________________________________________________________________________________________________________


#Now we want to order the billable locations by region name, then by location name.
#

class Location < ActiveRecord::Base
  belongs_to :region
end

class Region < ActiveRecord::Base
  has_many :locations
end

#So straigth away we can do the following query to get the billable locations to be ordered by region name then by location name:
#

Location.joins(:region).merge(Region.order(:name)).order(:name)

#Which gives us the following:
#

    locations             |    regions
id    name    region_id   |   id     name
1    Boston     1         |    1     East
2    New York   1         |    1     East
3    Denver     2         |    2     West


#So now we can create our method on the model to scope things:
#

class Location < ActiveRecord::Base
  def self.billable
    joins(people: :role).where(roles: { billable: true }).distinct
  end

  def self.by_region_and_location_name
    joins(:region).merge(Region.order(:name)).order(:name)
  end
end

#Now the problem that we are going to have is we won't be able to join our scopes and do:
#

XXXXXX Location.billable.by_region_and_location_name XXXXXX
#This is because the (distinct) method.
#We need to use a sub-query with the (from) method
#Let's use it to first return distinct billable locations.
#
Location.from(Location.billable, :locations)
#Which returns this:
#
    locations
id    name    region_id
3    Denver     2
1    Boston     1

#So now we can put it all together
#

Location.from(Location.billable, :locations).by_region_and_location_name

    locations            |   regions
id    name    region_id  |  id   name
1    Boston       1      |  1   East
3    Denver       2      |  2   West

