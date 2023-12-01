# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  ai_enabled             :boolean          default(FALSE)
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
  has_one :current_user_selection, -> { where(current: true) }, class_name: "UserSelection"
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  after_save :ensure_current_user_selection

  SUPER_ADMIN_ID = ENV.fetch("SUPER_ADMIN_ID", 1)

  def ensure_current_user_selection
    self.user_selections.current.first_or_create
  end

  def admin?
    id == SUPER_ADMIN_ID || ENV.fetch("ADMIN_EMAILS", "").split(",").include?(email)
  end

  # def ai_enabled?
  #   return false unless ai_enabled && ENV.fetch("AI_ENABLED", "false") == "true"
  # end

  def ai_enabled
    read_attribute(:ai_enabled) && ENV.fetch("AI_ENABLED", "false") == "true"
  end

  def self.super_admin
    User.find(SUPER_ADMIN_ID)
  end

  def make_selection(word, situation = nil)
    situation ||= self.current_situation
    Rails.logger.info "User: #{self.name} - Making selection: #{word} for situation: #{situation}"
    selection = self.user_selections.current.first_or_create(situation: situation)
    stipped_word = word.strip
    unless stipped_word.blank? || stipped_word == selection.words.last
      selection.words << stipped_word
    end
    selection.save
  end

  def remove_selection(word)
    selection = self.user_selections.current.first
    selection.words.delete(word)
    selection.save
  end

  def current_word_list
    self.user_selections.current.first&.words || []
  end

  def reset_user_selections(words = [])
    old_selection = self.user_selections.current.first
    old_selection.update(current: false) if old_selection
    new_selection = self.user_selections.create(current: true)
    new_selection.words = words
    new_selection.save
  end

  def add_to_user_selections(words)
    selection = self.user_selections.current.first_or_create
    if selection.words.blank?
      selection.words = words
    else
      selection.words << words
    end
    selection.words.flatten!
    selection.save
  end

  def current_word
    current_word_list.last
  end

  def current_response_board
    ResponseBoard.find_by(name: current_word)
  end

  def current_situation
    current_user_selection.situation
  end
end
