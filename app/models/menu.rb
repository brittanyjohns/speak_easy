# == Schema Information
#
# Table name: menus
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Menu < ApplicationRecord
    has_many :docs, as: :documentable, dependent: :destroy
    has_many :boards, through: :docs
end
