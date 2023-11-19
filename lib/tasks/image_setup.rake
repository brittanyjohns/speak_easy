namespace :images do
  desc "Categorizes images"
  # CREATE_AI_IMAGES=false rails images:categorize
  task categorize: [:environment] do
    CREATE_AI_IMAGES = ENV["CREATE_AI_IMAGES"] || true
    puts "Categorizing images..."
    puts "CREATE_AI_IMAGES: #{CREATE_AI_IMAGES}"
    categorized_word_list = [
      { "category": "Food & Drink", "label": "hamburger" },
      { "category": "Feelings & Actions", "label": "to sleep" },
      { "category": "Food & Drink", "label": "sandwich" },
      { "category": "Food & Drink", "label": "apple" },
      { "category": "Food & Drink", "label": "cookie" },
      { "category": "Food & Drink", "label": "chicken" },
      { "category": "Food & Drink", "label": "crackers" },
      { "category": "Feelings & Actions", "label": "to talk" },
      { "category": "Food & Drink", "label": "chocolate" },
      { "category": "Things & Stuff", "label": "my book" },
      { "category": "Food & Drink", "label": "milk" },
      { "category": "Feelings & Actions", "label": "more" },
      { "category": "Feelings & Actions", "label": "please" },
      { "category": "Feelings & Actions", "label": "bake" },
      { "category": "Things & Stuff", "label": "toilet" },
      { "category": "Food & Drink", "label": "water" },
      { "category": "Family & People", "label": "a friend" },
      { "category": "Food & Drink", "label": "food" },
      { "category": "Food & Drink", "label": "sweet" },
      { "category": "Food & Drink", "label": "medicine" },
      { "category": "Feelings & Actions", "label": "is" },
      { "category": "Feelings & Actions", "label": "yum" },
      { "category": "Food & Drink", "label": "meal" },
      { "category": "Feelings & Actions", "label": "eat" },
      { "category": "Feelings & Actions", "label": "want" },
      { "category": "Feelings & Actions", "label": "good" },
      { "category": "Feelings & Actions", "label": "bite" },
      { "category": "Feelings & Actions", "label": "hungry" },
      { "category": "Feelings & Actions", "label": "full" },
      { "category": "Feelings & Actions", "label": "is fun" },
      { "category": "Food & Drink", "label": "snack" },
      { "category": "Feelings & Actions", "label": "chew" },
      { "category": "Food & Drink", "label": "pizza" },
      { "category": "Feelings & Actions", "label": "swallow" },
      { "category": "Feelings & Actions", "label": "swim" },
      { "category": "Feelings & Actions", "label": "taste" },
      { "category": "Play & Entertainment", "label": "I play" },
      { "category": "Food & Drink", "label": "plate" },
      { "category": "Food & Drink", "label": "dish" },
      { "category": "Food & Drink", "label": "juice" },
      { "category": "Food & Drink", "label": "dinner" },
      { "category": "Feelings & Actions", "label": "it moves" },
      { "category": "Food & Drink", "label": "lunch" },
      { "category": "Feelings & Actions", "label": "I need" },
      { "category": "Feelings & Actions", "label": "to go" },
      { "category": "Play & Entertainment", "label": "to play" },
      { "category": "Things & Stuff", "label": "my toy" },
      { "category": "Feelings & Actions", "label": "a hug" },
      { "category": "Colors & Shapes", "label": "colors are" },
      { "category": "Feelings & Actions", "label": "a break" },
      { "category": "Feelings & Actions", "label": "a turn" },
      { "category": "Feelings & Actions", "label": "it makes" },
      { "category": "Feelings & Actions", "label": "I want" },
      { "category": "Food & Drink", "label": "soda" },
      { "category": "Feelings & Actions", "label": "to eat" },
      { "category": "Play & Entertainment", "label": "to watch" },
      { "category": "Food & Drink", "label": "to drink" },
      { "category": "Food & Drink", "label": "tea" },
      { "category": "Feelings & Actions", "label": "to read" },
      { "category": "Feelings & Actions", "label": "to learn" },
      { "category": "Food & Drink", "label": "straw" },
      { "category": "Feelings & Actions", "label": "to see" },
      { "category": "Food & Drink", "label": "coffee" },
      { "category": "Food & Drink", "label": "drink" },
      { "category": "Feelings & Actions", "label": "thirsty" },
      { "category": "Food & Drink", "label": "bottle" },
      { "category": "Food & Drink", "label": "cup" },
      { "category": "Feelings & Actions", "label": "it" },
      { "category": "Places & Nature", "label": "ocean" },
      { "category": "Food & Drink", "label": "sippy" },
      { "category": "Feelings & Actions", "label": "splash" },
      { "category": "Feelings & Actions", "label": "thirst" },
      { "category": "Family & People", "label": "I" },
      { "category": "Feelings & Actions", "label": "to" },
      { "category": "Family & People", "label": "me" },
      { "category": "Feelings & Actions", "label": "some" },
      { "category": "Feelings & Actions", "label": "that" },
      { "category": "Family & People", "label": "you" },
      { "category": "Feelings & Actions", "label": "can" },
      { "category": "Feelings & Actions", "label": "now" },
      { "category": "Play & Entertainment", "label": "play" },
      { "category": "Feelings & Actions", "label": "do" },
      { "category": "Feelings & Actions", "label": "go" },
      { "category": "Food & Drink", "label": "fruit" },
      { "category": "Feelings & Actions", "label": "like" },
      { "category": "Feelings & Actions", "label": "am" },
      { "category": "Feelings & Actions", "label": "see" },
      { "category": "Feelings & Actions", "label": "have" },
      { "category": "Feelings & Actions", "label": "need" },
      { "category": "Feelings & Actions", "label": "feel" },
      { "category": "Feelings & Actions", "label": "think" },
      { "category": "Feelings & Actions", "label": "hello" },
      { "category": "Food & Drink", "label": "a snack" },
      { "category": "Things & Stuff", "label": "my iPad" },
      { "category": "Places & Nature", "label": "outside" },
      { "category": "Food & Drink", "label": "a drink" },
      { "category": "Feelings & Actions", "label": "I love it" },
      { "category": "Things & Stuff", "label": "its mine" },
      { "category": "Things & Stuff", "label": "its new" },
      { "category": "Feelings & Actions", "label": "I share it" },
      { "category": "Things & Stuff", "label": "its broken" },
    ]

    categorized_word_list.each do |content|
      label = content[:label] || content["label"]
      category = content[:category] || content["category"]
      puts "Label: #{label} - Category: #{category}"
      img = Image.find_by(label: label, private: false)
      puts "Found image #{img.id}: #{img.label} - #{img.category}" if img
      unless img
        img = Image.create(label: label, send_request_on_save: CREATE_AI_IMAGES, private: false, category: category, ai_generated: CREATE_AI_IMAGES)
        puts "#{img.id} Created image: #{img.label}"
      else
        if category && img.category != category
          img.category = category
          if img.save
            puts "#{img.id} Updated image: #{img.label} - #{img.category}"
          end
        end
      end
    end
  end
end
