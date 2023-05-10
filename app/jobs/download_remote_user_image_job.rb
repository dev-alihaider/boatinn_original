# frozen_string_literal: true

class DownloadRemoteUserImageJob < ApplicationJob # :nodoc:
  queue_as :default

  def perform(image, url)
    image.download_remote_attachment(url)
  end
end
