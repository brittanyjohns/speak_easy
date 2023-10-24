module SpeechHelper
  def default_options
    { lang: "en-us",
      pitch: 50,
      speed: 170,
      capital: 1,
      amplitude: 100,
      quiet: true }
  end

  def speak
    lang = default_options[:lang]
    pitch = default_options[:pitch]
    speed = default_options[:speed]
    capital = default_options[:capital]
    amplitude = default_options[:amplitude]
    quiet = default_options[:quiet]
    speech = ESpeak::Speech.new(name, voice: lang, pitch: pitch, speed: speed, capital: capital, amplitude: amplitude, quiet: quiet)
    speech.speak # invokes espeak
  end
end
