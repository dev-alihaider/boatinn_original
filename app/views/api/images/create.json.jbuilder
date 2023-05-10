# frozen_string_literal: true

json.id @image.id
json.priority @image.priority
json.created_at @image.created_at
json.attachment_content_type @image.attachment_content_type
json.attachment_file_name @image.attachment_file_name
json.attachment_file_size @image.attachment_file_size
json.url image_url(@image.attachment.url(:medium))
