# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  name                   :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  has_many :boards, dependent: :destroy
  has_many :images
  has_many :user_selections, dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def admin?
    id == 1
  end

  def make_selection(word)
    selection = self.user_selections.current.first_or_create
    selection.words << word
    selection.save
  end

  def current_word_list
    self.user_selections.current.first_or_create.words
  end

  def reset_user_selections(words = [])
    old_selection = self.user_selections.current.first
    old_selection.update(current: false) if old_selection
    new_selection = self.user_selections.create(current: true)
    new_selection.words = words
    new_selection.save
  end
end
