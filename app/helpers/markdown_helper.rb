module MarkdownHelper
  def markdown(text)
    if text.is_a?(String)
      markdown_renderer.render(text).to_html.html_safe
    end
  end

  def markdown_renderer
    @markdown_renderer ||= Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(
        filter_html: true,
        hard_wrap: true,
        no_images: true,
        no_styles: true
      ),
      strikethrough: true,
      underline: true,
      autolink: true
    )
  end

  def markdown_line_break_to_paragraph(text)
    if text.is_a?(String)
      lines = trim_array(text.split(/\n/))
      lines.map do |line|
        markdown_renderer.render(line).html_safe
      end.join(' ').html_safe
    end
  end

  def trim_array(xs)
    xs.drop_while { |x| x.blank? }.reverse.drop_while { |x| x.blank? }.reverse
  end
end
