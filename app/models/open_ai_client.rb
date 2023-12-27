require "openai"

class OpenAiClient
  DEFAULT_MODEL = "text-davinci-001"
  TURBO_MODEL = "gpt-3.5-turbo"

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
    if response
      img_url = response.dig("data", 0, "url")
      puts "*** ERROR *** Invaild Image Response: #{response}" unless img_url
    else
      puts "**** Client ERROR **** \nDid not receive valid response.\n#{response}"
    end
    img_url
  end

  def self.describe_image(img_url)
    # model: "gpt-4-vision-preview",
    # messages: [
    #   {
    #     role: "user",
    #     content: [
    #       { type: "text", text: "What’s in this image?" },
    #       {
    #         type: "image_url",
    #         image_url: {
    #           "url": "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg",
    #         },
    #       },
    #     ],
    #   },
    # ],
    puts "describe: #{img_url} \n openai_client: #{openai_client}"
    response = openai_client.chat(parameters: { model: "gpt-4-vision-preview", messages: [{ role: "user", content: [{ type: "text", text: "What’s in this image?" }, { type: "image_url", image_url: { url: img_url } }] }] })
    puts "*** ERROR *** Invaild Image Description Response: #{response}" unless response
    # save_response_locally(response)
    response
  end

  def self.save_response_locally(response)
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
