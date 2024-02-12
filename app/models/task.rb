class Task < ActiveRecord::Base
  # ActiveRecord is the ORM (Object Relational Mapper) that we are using
  # with Sinatra.  ActiveRecord was extracted from Ruby on Rails, and it
  # is well documented as part of that framework.
  #
  # You can read all about it here:
  #
  # https://guides.rubyonrails.org/active_record_basics.html
  belongs_to :user

  validates :description, presence: true
  validates :user, presence: true
end
