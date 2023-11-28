class User < ApplicationRecord
  has_secure_password

  validates :username, presence: true, uniqueness: true
  validates :email, allow_blank: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}

  has_many :saves
end
