module SpeechHelper
  def default_options
    { lang: "en-us",
      pitch: 50,
      speed: 170,
      capital: 1,
      amplitude: 100,
      quiet: true }
  end

  def speech
    lang = default_options[:lang]
    pitch = default_options[:pitch]
    speed = default_options[:speed]
    capital = default_options[:capital]
    amplitude = default_options[:amplitude]
    quiet = default_options[:quiet]
    speech = ESpeak::Speech.new(speak_name, voice: lang, pitch: pitch, speed: speed, capital: capital, amplitude: amplitude, quiet: quiet)
  end

  def speak
    speech.speak # invokes espeak
  end

  def create_mp3
    speech.bytes_wav
  end

  def save_audio
    # file = speech.save("#{speak_name}_#{id}.mp3")
    file_data = create_mp3
    io = StringIO.new(file_data)

    puts "===> #{io.class}"
    self.audio_clip.attach(io: io, filename: "#{speak_name}_#{id}.mp3")
  end
end
