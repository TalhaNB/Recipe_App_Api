class User < ApplicationRecord
  has_secure_password
  has_one_attached :avatar

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :password_digest, presence: true
end
