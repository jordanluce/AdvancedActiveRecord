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
