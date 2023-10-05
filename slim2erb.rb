# RoR view file syntax conversion script: Slim to ERB
# Hey kids! Do you love coffeescript? Well f*ck you and your preferences for syntax sugar coating. Now use this to convert your slim views and partials into standard ERB form and keep everyone on the same page (because slim is stupid)

require 'openai'

# Configure OpenAI API client
Openai.api_key = 'YOUR_OPENAI_API_KEY'

# Recursively find all .slim files in the views directory
Dir.glob("app/views/**/*.slim") do |slim_file|
  # Read the slim file content
  slim_content = File.read(slim_file)

  begin
    # Use OpenAI API to convert slim to ERB (Note: Actual implementation might differ based on API capabilities and usage)
    response = Openai.Completion.create(
      engine: "text-davinci-003",
      prompt: "Convert the following Slim code to ERB: #{slim_content}",
      max_tokens: 1000
    )

    erb_content = response.choices.first.text.strip

    # Write the converted content to a new .erb file in the same directory
    erb_file = slim_file.sub(/\.slim\z/, '.erb')
    File.write(erb_file, erb_content)

    puts "Converted #{slim_file} to #{erb_file}"
  rescue => e
    puts "Failed to convert #{slim_file}: #{e.message}"
  end
end
