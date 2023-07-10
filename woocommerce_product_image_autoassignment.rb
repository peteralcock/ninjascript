require 'json'
require 'woocommerce_api'
require 'openai'
require 'metainspector'

ENV['WORDPRESS_URL'] = "https://example.com/wp-json"
ENV['WOO_CONSUMER_KEY'] = "ck_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
ENV['WOO_CONSUMER_SECRET'] = "cs_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
woocommerce = WooCommerce::API.new(
 "https:/example.com",
  ENV['WOO_CONSUMER_KEY'],
  ENV['WOO_CONSUMER_SECRET'],
  {
    wp_api: true,
    version: 'wc/v3'
  }
)
products = woocommerce.get "products"
puts products
products.each do |product|
  # Retrieve the product name or any other necessary information
  product_name = product['name']

  # Use the OpenAI API to get the Wikipedia page URL for the product
#  openai_response = OpenAI::Client.new(api_key: 'YOUR_API_KEY').completions.create(
#    engine: 'text-davinci-003',
#    prompt: "Find the Wikipedia URL for #{product_name}.",
#    max_tokens: 100
#  )
#  wikipedia_url = openai_response['choices'][0]['text'].strip

  # Use the MetaInspector gem to fetch the best image URL from the Wikipedia page
  page = MetaInspector.new(wikipedia_url)
  image_url = page.images.best

  # Update the product with the fetched image URL as its featured image
  updated_product = {
    images: [
      {
        src: image_url,
        position: 0
      }
    ]
  }
puts wikipedia_url
puts image_url
# puts product['id']
#  woocommerce.put("products/#{product['id']}", updated_product)
end

