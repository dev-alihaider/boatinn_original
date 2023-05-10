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

class Asset < ApplicationRecord # :nodoc:
  belongs_to :assetable, polymorphic: true, touch: true, optional: true

  # TODO: Remove styles and add child images models for each used model.
  has_attached_file :attachment,
                    styles: { slideshow_full: '1349×812',
                              slideshow_mobile: '460х277',
                              medium: '430x275#',
                              logo: '191x42',
                              favicon: '25x25',
                              community_preferences_full:'350x350',
                              community_preferences_mobile: '350x350',
                              experience_gallery_narrow_full: '621x240',
                              experience_gallery_narrow_mobile: '480х240',
                              experience_gallery_wide_full: '976x240' },
                    default_url: '/images/:style/missing.png'

  validates_attachment_content_type :attachment, content_type: %r{\Aimage\/.*\z}
  validates_attachment_presence :attachment

  def download_remote_attachment(url)
    self.attachment = URI.parse(url)
    save
  end
end
