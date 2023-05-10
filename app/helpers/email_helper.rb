module EmailHelper
  def email_image_tag(image, **options)
    image_tag image_to_base64(image), **options
  end

  def image_to_base64(image_path)
    image_path = Rails.root.join("app/assets/images/#{image_path}")
    code = Base64.strict_encode64(File.read(image_path))
    mime = Rack::Mime.mime_type(File.extname(image_path))
    "data:#{mime};base64,#{code}"
  end

end