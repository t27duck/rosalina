# frozen_string_literal: true

require "bot/eight_ball"

module EightballControllerCoontainer
  extend Discordrb::Commands::CommandContainer

  command :8ball,
          description: "Ask the magic 8-ball a question and get an 'answer'.",
          usage: "%8ball I have a question?" do |event, *args|

    question = args.to_a.join.squish
    if question.end_with?('?')
      event.respond(EightBall.shake)
    else
      event.respond("Ask a question!")
    end
  end
end
