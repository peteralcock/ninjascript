
<?php
/**
 * Plugin Name: Auto Fill SKU for Books
 * Description: Automatically fills in the SKU for products in the "books" category using OpenAI to fetch the ISBN.
 * Version: 1.0
 * Author: Your Name
 */

// Hook into the product save action
add_action('save_post_product', 'auto_fill_sku_for_books');

function auto_fill_sku_for_books($post_id) {
    // Get the product object
    $product = wc_get_product($post_id);

    // Check if the product is in the "books" category
    if (has_term('books', 'product_cat', $post_id)) {
        // Fetch the ISBN using OpenAI
        $isbn = fetch_isbn_from_openai($product->get_name());

        if ($isbn) {
            // Generate SKU from the ISBN
            $sku = 'BOOK-' . $isbn;

            // Update the product SKU
            $product->set_sku($sku);
            $product->save();
        }
    }
}

function fetch_isbn_from_openai($product_name) {
    // Replace 'YOUR_OPENAI_API_KEY' with your actual OpenAI API key
    $api_key = 'YOUR_OPENAI_API_KEY';

    // OpenAI API endpoint
    $endpoint = 'https://api.openai.com/v1/engines/davinci-codex/completions';

    // Request headers
    $headers = array(
        'Content-Type: application/json',
        'Authorization: Bearer ' . $api_key
    );

    // Request data
    $data = array(
        'prompt' => 'ISBN number for book: ' . $product_name,
        'max_tokens' => 1,
        'temperature' => 0.8,
        'top_p' => 1,
        'n' => 1,
        'stop' => '\n'
    );

    // Send the API request
    $response = wp_remote_post(
        $endpoint,
        array(
            'headers' => $headers,
            'body' => json_encode($data),
        )
    );

    // Check if the API request was successful
    if (is_wp_error($response)) {
        // Handle error case
        error_log('OpenAI API request failed: ' . $response->get_error_message());
        return '';
    }

    // Parse the API response
    $response_body = json_decode(wp_remote_retrieve_body($response), true);

    if (isset($response_body['choices'][0]['text'])) {
        // Extract the ISBN number from the API response
        $isbn = extract_isbn_number($response_body['choices'][0]['text']);
        return $isbn;
    }

    return '';
}

function extract_isbn_number($text) {
    // Use regular expressions to extract the ISBN number
    preg_match('/\bISBN[-]*(1[03])*[:]?(\s)*(97([89]))?[-]*(\d+[-]*){9,11}[\dxX]\b/', $text, $matches);

    if (isset($matches[0])) {
        return $matches[0];
    }

    return '';
}
