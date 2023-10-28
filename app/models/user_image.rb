# == Schema Information
#
# Table name: user_images
#
#  id         :bigint           not null, primary key
#  favorite   :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  image_id   :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_images_on_image_id  (image_id)
#  index_user_images_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (image_id => images.id)
#  fk_rails_...  (user_id => users.id)
#
class UserImage < ApplicationRecord
  belongs_to :user
  belongs_to :image
end
