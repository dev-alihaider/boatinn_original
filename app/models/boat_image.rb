# frozen_string_literal: true
# == Schema Information
#
# Table name: assets
#
#  id                      :bigint(8)        not null, primary key
#  attachment_file_name    :string
#  attachment_content_type :string
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#  assetable_type          :string
#  assetable_id            :bigint(8)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  priority                :integer          default(0), not null
#

class BoatImage < Asset # :nodoc:
  # To avoid search images in `boat_images/` directory.
  # If remove this then add Rake task for images copy:
  # `assets/ -> boat_images/`.
  ATTACHMENT_URL = '/system/assets/:attachment/:id_partition/:style/:filename'
  MAX_ATTACHMENT_SIZE = 5.megabytes

  has_attached_file :attachment,
                    styles: { medium: '430x275#' },
                    url: ATTACHMENT_URL

  validates_attachment :attachment, presence: true,
                                    content_type: {
                                      content_type: %w[image/jpeg image/png]
                                    },
                                    size: { less_than: MAX_ATTACHMENT_SIZE }

  after_validation :delete_duplicated_errors

  private

  # Fix Paperclip duplication error messages for `attachment_file_size`.
  #
  # See: https://github.com/thoughtbot/paperclip/pull/1554 and
  # https://github.com/thoughtbot/paperclip/commit/2aeb491fa79df886a39c35911603fad053a201c0
  #
  # ActiveModel::Errors
  #   messages: { attachment_file_size: ['must be less than 5 MB'],
  #               attachment: ['must be less than 5 MB'] }
  def delete_duplicated_errors
    errors.messages.delete(:attachment)
    errors.messages[:attachment_content_type].uniq!
    errors.messages[:attachment_file_size].uniq!
  end
end
