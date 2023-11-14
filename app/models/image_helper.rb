require "open-uri"

module ImageHelper
  def name_to_send
    open_ai_opts[:prompt] || name
  end

  def save_image(url)
    begin
      downloaded_image = URI.open(url,
                                  "User-Agent" => "Ruby/#{RUBY_VERSION}",
                                  "From" => "foo@bar.invalid",
                                  "Referer" => "http://www.ruby-lang.org/")
      self.saved_image.attach(io: downloaded_image, filename: "img_#{id}.png")
    rescue => e
      puts "ImageHelper ERROR: #{e.inspect}"
      raise e
    end
  end

  def create_image
    img_url = OpenAiClient.new(open_ai_opts).create_image
    if img_url
      # self.update(image_url: img_url)
      save_image(img_url)
    else
      puts "**** ERROR **** \nDid not receive valid response.\n"
      return false
    end
  end

  def create_image_variation(img_url = nil, user = nil)
    success = false
    img_url ||= main_doc.main_image_on_disk
    img_variation_url = OpenAiClient.new(open_ai_opts).create_image_variation(img_url)
    if img_variation_url
      save_image(img_variation_url)
      success = true
    else
      puts "**** ERROR **** \nDid not receive valid response.\n"
    end
    success
  end

  def random_prompts
    [
      "Create an enchanting image of a magical forest at dusk.",
      "Design a futuristic cityscape bustling with flying cars and towering skyscrapers.",
      "Capture the serenity of a secluded beach with crystal-clear turquoise waters.",
      "Illustrate a whimsical underwater world filled with vibrant coral reefs and friendly sea creatures.",
      "Craft a breathtaking image of a cascading waterfall nestled within a lush, verdant jungle.",
      "Paint a picture of a cozy cottage nestled amidst rolling green hills and blooming flowers.",
      "Imagine an awe-inspiring celestial scene of a starry night sky with a shimmering Milky Way.",
      "Bring to life an adorable image of playful puppies frolicking in a sunlit meadow.",
      "Compose a captivating image of a bustling marketplace filled with colorful fruits, vegetables, and people.",
      "Illustrate the power and beauty of a thunderstorm with dramatic lightning bolts and dark clouds.",
      "Create an idyllic countryside landscape with grazing farm animals and a picturesque farmhouse.",
      "Design a fantastical image of mythical creatures like unicorns and dragons in a magical realm.",
      "Capture the excitement of a thrilling roller coaster ride with twists, turns, and smiling riders.",
      "Paint a tranquil scene of a peaceful lake reflecting a radiant sunrise or sunset.",
      "Imagine an imaginative image of a child's dream world with talking animals and floating islands.",
      "Bring to life a vibrant city street with bustling cafes, street performers, and colorful buildings.",
      "Compose a charming image of hot air balloons soaring over picturesque countryside scenery.",
      "Illustrate a dramatic and majestic image of a snow-covered mountain range.",
      "Create a mouthwatering image of a beautifully arranged plate of gourmet food.",
      "Design a futuristic space station orbiting a distant planet against the backdrop of the cosmos.",
      "Capture the elegance of a ballet dancer gracefully performing on stage.",
      "Paint a nostalgic scene of children playing in a treehouse surrounded by lush trees.",
      "Imagine an electrifying image of a concert crowd cheering and waving colorful glow sticks.",
      "Bring to life the excitement of a thrilling sports moment, such as a winning goal or a triumphant finish line.",
      "Compose a captivating image of a vibrant carnival with rides, games, and festive decorations.",
    ]
  end

  def image_types
    ["Sigma 24mm f/8",
     "Pixel Art",
     "Anime",
     "Digital art",
     "Photography",
     "Sculpture",
     "Printmaking",
     "Graphic design",
     "Ceramic pottery",
     "Glassblowing",
     "Stained glass",
     "Metal sculpture",
     "Street art",
     "Graffiti art",
     "Calligraphy",
     "Pencil drawing",
     "Ink illustration",
     "Cartoon art",
     "Comic book art",
     "Mosaic art",
     "Textile art",
     "Embroidery",
     "Jewelry making",
     "Installation art",
     "Performance art",
     "Video art",
     "Animation",
     "Concept art",
     "Abstract art",
     "Realism art",
     "Impressionism",
     "Surrealism",
     "Pop art",
     "Minimalism",
     "Cubism",
     "Renaissance art",
     "Modern art",
     "Contemporary art"]
  end

  def remove_extras_from_prompt(prompt_text)
    return "" unless prompt_text
    image_types.each do |item|
      art_type = item.downcase
      normalized_prompt_text = prompt_text&.downcase
      prompt_text = normalized_prompt_text&.gsub(art_type, "")&.strip
    end
    prompt_text
  end
end
