require "openai"

class OpenAiClient
  DEFAULT_MODEL = "text-davinci-001"
  TURBO_MODEL = "gpt-3.5-turbo"
  GPT_4_MODEL = "gpt-4-1106-preview"

  def initialize(opts)
    @messages = opts["messages"] || opts[:messages] || []
    @prompt = opts["prompt"] || opts[:prompt] || "backup"
  end

  def self.openai_client
    @openai_client ||= OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"))
  end

  def openai_client
    @openai_client ||= OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"))
  end

  def create_image
    response = openai_client.images.generate(parameters: { prompt: @prompt, size: "512x512" })
    puts "\n\nRESPONSE: #{response}\n\n"
    if response
      img_url = response.dig("data", 0, "url")
      puts "*** ERROR *** Invaild Image Response: #{response}" unless img_url
    else
      puts "**** Client ERROR **** \nDid not receive valid response.\n#{response}"
    end
    img_url
  end

  def self.describe_image(img_url)
    response = openai_client.chat(parameters: { model: "gpt-4-vision-preview", messages: [{ role: "user", content: [{ type: "text", text: "What’s in this image?" }, { type: "image_url", image_url: { url: img_url } }] }] })
    puts "*** ERROR *** Invaild Image Description Response: #{response}" unless response
    # save_response_locally(response)
    response
  end

  def clarify_image_description(image_description)
    puts "Missing image description.\n" && return unless image_description
    @model = GPT_4_MODEL
    @messages = [{ role: "user", content: [{ type: "text", text: "Please parse the following text from a kid's menu and form a clear list of the food and beverage options ONLY.
    Create a short image description for each item based on the name and description.
    The NAME of the food or beverage is the most important part. Ensure that the name is accurate.
    The description is optional.
    Respond as json formatted as: #{expected_json_schema}\n
     #{image_description}" }] }]
    puts "Sending to model: #{@model}\n"
    response = create_chat
    puts "*** ERROR *** Invaild Image Description Response: #{response}" unless response
    response
  end

  def expected_json_schema
    {
      "food": [
        {
          "name": "Chicken Tenders",
          "description": "Served with french fries and honey mustard sauce.",
          "image_description": "Chicken tenders with french fries and honey mustard sauce.",
        },
        {
          "name": "Cheeseburger",
          "description": "Served with french fries.",
          "image_description": "Cheeseburger with french fries.",
        },
      ],
      "drinks": [
        {
          "name": "Milk",
        },
        {
          "name": "Apple Juice",
        },
      ],
    }
  end

  def save_response_locally(response)
    puts "*** ERROR *** Invaild Image Description Response: #{response}" unless response
    File.open("response.json", "w") { |f| f.write(response) }
  end

  def create_image_variation(img_url, num_of_images = 1)
    response = openai_client.images.variations(parameters: { image: img_url, n: num_of_images })
    img_variation_url = response.dig("data", 0, "url")
    puts "*** ERROR *** Invaild Image Variation Response: #{response}" unless img_variation_url
    img_variation_url
  end

  def create_chat
    puts "**** ERROR **** \nNo messages provided.\n" unless @messages
    puts "Messages: #{@messages}\n"
    opts = {
      model: TURBO_MODEL, # Required.
      messages: @messages, # Required.
      temperature: 0.7,
    }
    begin
      response = openai_client.chat(
        parameters: opts,
      )
    rescue => e
      puts "**** ERROR **** \n#{e.message}\n"
    end
    puts response.dig("choices", 0, "message", "content")
    if response
      @role = response.dig("choices", 0, "message", "role")
      @content = response.dig("choices", 0, "message", "content")
    else
      puts "**** ERROR **** \nDid not receive valid response.\n"
    end
    { role: @role, content: @content }
  end

  def self.ai_models
    @models = openai_client.models.list
  end
end
