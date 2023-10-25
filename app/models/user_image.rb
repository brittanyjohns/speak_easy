# == Schema Information
#
# Table name: user_images
#
#  id         :integer          not null, primary key
#  favorite   :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  image_id   :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_user_images_on_image_id  (image_id)
#  index_user_images_on_user_id   (user_id)
#
# Foreign Keys
#
#  image_id  (image_id => images.id)
#  user_id   (user_id => users.id)
#
class UserImage < ApplicationRecord
  belongs_to :user
  belongs_to :image
end