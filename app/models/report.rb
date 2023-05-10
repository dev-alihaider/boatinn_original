# frozen_string_literal: true

# == Schema Information
#
# Table name: reports
#
#  id              :bigint(8)        not null, primary key
#  author_id       :bigint(8)
#  reportable_type :string
#  reportable_id   :bigint(8)
#  reason          :integer
#  details         :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Report < ApplicationRecord # :nodoc:
  belongs_to :author, class_name: 'User'
  belongs_to :reportable, polymorphic: true

  validates :author, :reason, presence: true

  def about_review?
    reportable_type == Review.to_s
  end

  def about_user?
    reportable_type == User.to_s
  end
end
