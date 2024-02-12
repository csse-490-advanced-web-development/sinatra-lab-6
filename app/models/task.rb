class Task < ActiveRecord::Base
  # ActiveRecord is the ORM (Object Relational Mapper) that we are using
  # with Sinatra.  ActiveRecord was extracted from Ruby on Rails, and it
  # is well documented as part of that framework.
  #
  # You can read all about it here:
  #
  # https://guides.rubyonrails.org/active_record_basics.html
  belongs_to :user

  default_scope { order(id: :asc) }

  validates :description, presence: true
  validates :user, presence: true

  def as_json
    { id: id, description: description, complete: complete }
  end
end
