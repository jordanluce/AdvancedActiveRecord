class Person < ActiveRecord::Base
  belongs_to :manager, class_name: "Person", foreign_key: :manager_id
  has_many :employees, class_name: "Person", foreign_key: :manager_id
  belongs_to :location
  belongs_to :role
end

People.all

  id    name    role_id   location_id     manager_id    salary
  1     Eve       2           2               NULL      50000
  2     Bill      2           1               NULL      40000
  3     Wendell   1           1               1         35000
  4     Christie  1           1               1         30000
  5     Sandy     1           3               2         45000


  Person.count
  5

  Person.average(:salary)
  40000.000000000000

#Combining aggregations with other queries
#
  Person.
    joins(:role).
    where(roles: { billable: false }).
    sum(:salary)

  90000

#Aggregate by category with the group method
  #
  Person.
    joins(:role).
    group("roles.name").
    average(:salary)

  name        avg
Manager     45000.000000000000
Developer   36666.666666666667


#How ActiveRecord aliases tables
#
Person.
  joins(:employees).
  group("people.name").
  count("employees_people.id")

name  count
Eve     2
Bill    1

#Notice how this returns people that have employees only, what if we wanted to see everyone even the ones without employees...
#

Person.
  joins("LEFT JOIN people employees ON employees.manager_id = people.id").
  group("people.name").
  count("employees.id")

name      count
Christie    0
Sandy       0
Wendell     0
Eve         2
Bill        1

__________________________________________________________________________________________________________________________________

#Now let's try to get people with lower than average salaries at their location....
#

Person.
  joins(
    "INNER JOIN (" +
      Person.
        select("location_id, AVG(salary) as average").
        group("location_id").
        to_sql
    ") salaries " \
    "ON salaries.location_id - people.location_id"
 ).
 where("people.salary < salaries.average")


#This is essentially the same thing as Person.group("location_id").average(:salary), but this way we can call to_sql on it (since it is still a relation, rather than the scalar result).

#We now have a virtual table of the average salary at each location, aliased as salaries, which we join on to the people table (using their location_id to match up rows).

#Finally, with the new columns available, we can use a simple where clause to filter our results down.
 #
 #
 #
                    people                                                salaries
id    name    role_id     location_id   manager_id  salary      location_id     average
4   Christie    1               1           1       30000           1         35000.000000000000
