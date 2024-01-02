# == Schema Information
#
# Table name: docs
#
#  id                :bigint           not null, primary key
#  documentable_type :string           not null
#  image_description :text
#  name              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  documentable_id   :bigint           not null
#
# Indexes
#
#  index_docs_on_documentable  (documentable_type,documentable_id)
#
require "test_helper"

class DocTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
