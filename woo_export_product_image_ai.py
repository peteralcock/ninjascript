import os
import pandas as pd
import requests
import openai
from slugify import slugify

# Prepare images directory
if not os.path.exists('images'):
    os.makedirs('images')

# Read the WooCommerce CSV product export
df = pd.read_csv('products.csv')
# Iterate over each product in the CSV
for index, row in df.iterrows():
    product_filename = row['Name']  # Replace 'Name' with the actual column name for the product name in your CSV
    product_name = row['Description']  # Replace 'Name' with the actual column name for the product name in your CSV
    
    # Generate image using OpenAI API (replace with actual API call if available)
    openai.api_key = ""
    image_url = openai.Image.create(
    prompt=product_name,
    n=1,
    size="1024x1024"
    )

    if image_url:
        print(image_url)       
        # Download the image
        filename = slugify(product_filename)
        with open('images/{}.jpg'.format(filename), 'wb') as f:
            f.write(requests.get(image_url["data"][0]["url"]).content)
        print(filename)
    else:
        print('Error generating image for product: {}'.format(product_name))
