module AssetsHelper
  def include_vue_js
    content_for(:head) do
      javascript_include_tag(Rails.env.development? ? 'vendor/vue' : 'vendor/vue.min')
    end
  end

  def include_stripe_js
    content_for(:head) do
      "
        #{javascript_include_tag('https://js.stripe.com/v3/')}
        <script>window.stripe = Stripe('#{ENV['STRIPE_PUBLISH_KEY']}')</script>
      ".html_safe
    end
  end
end
