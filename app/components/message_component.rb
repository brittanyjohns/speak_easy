class MessageComponent < ViewComponent::Base
  erb_template <<-ERB
      <h1>Hello, <%= @name %>!</h1>
    ERB

  def initialize(name:)
    @name = name
  end
end
