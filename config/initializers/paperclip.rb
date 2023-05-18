# frozen_string_literal: true

Paperclip::UriAdapter.register
# Paperclip::Attachment.default_options[:path] = ':class/:attachment/:id_partition/:style/:filename'
Paperclip::Attachment.default_options[:storage] = :s3
Paperclip::Attachment.default_options[:s3_protocol] = 'https'
