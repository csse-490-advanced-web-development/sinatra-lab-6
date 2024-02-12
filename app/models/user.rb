class User < ActiveRecord::Base
  has_many :tasks
  has_secure_password

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid email address" }
  validates :password, confirmation: true
  validates :password_confirmation, presence: true

  def as_json
    { email: email }
  end
end
