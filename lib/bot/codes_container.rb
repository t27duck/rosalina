# frozen_string_literal: true

require "bot/code_handler"

module CodesContainer
  extend Discordrb::Commands::CommandContainer

  command :codes,
          description: "Stash and display your gaming codes. Run '%codes help' for more info",
          usage: "%codes command [arg1] [arg2]" do |event, *args|

    arguments = args.to_a
    cmd = arguments.shift || "view"
    arg1 = arguments.shift
    arg2 = arguments.join(" ").presence
    begin
      CodeHandler.new(event).process(cmd, arg1, arg2)
    rescue StandardError => e
      Rails.logger.error(e.message)
      event.respond("Opps.. something broke.")
    end
  end
end
