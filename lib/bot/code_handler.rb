# frozen_string_literal: true

class CodeHandler
  def initialize(event)
    @event = event
    @discord_id = event.user.id
    @discord_username = event.user.username
  end

  def process(command, arg1, arg2)
    case command
    when "view"
      display_codes
    when "help"
      @event.respond(<<~TEXT)
        Code Service Commands:
        **%codes** - View your codes.
        **%codes add service code** - Adds a code for a service.
        **%codes remove service** - Removes the code stored for the given service.
        **%codes clear** - Removes all codes.
        Valid services: #{valid_systems.sort.join(' ')}
      TEXT
    when "add"
      add_code(arg1, arg2)
    when "remove"
      remove_code(arg1)
    when "clear"
      CodeList.where(discord_id: @discord_id).delete_all
      @event.respond("All of your codes are removed!")
    else
      @event.respond("Unknown command '#{command}'")
    end
  end

  private

  def display_codes
    return unless has_codes?

    @event.channel.send_embed do |embed|
      embed.title = "#{@discord_username}'s codes"
      embed.description = code_list.system_code_display
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: @event.user.avatar_url)
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Use '%codes help' for more info")
    end
  end

  def valid_systems
    CodeList::SYSTEM_CODE_MAP.keys
  end

  def add_code(system, code)
    system.downcase!
    return unless validate_system(system)

    if code.blank?
      @event.respond("Code not provided")
      return
    end

    code_list.system_codes[system] = code
    code_list.save!
    @event.respond("Code for '#{system}' added")
  end

  def remove_code(system)
    system.downcase!
    return unless validate_system(system)
    return unless has_codes?
    return unless has_code?(system)

    code_list.system_codes.delete(system)
    code_list.save!
    @event.respond("Code for '#{system}' removed!")
  end

  def code_list
    @code_list ||= CodeList.where(discord_id: @discord_id).first_or_initialize
  end

  def validate_system(system)
    return true if valid_systems.include?(system)

    @event.respond("Invalid system '#{system}'")
    false
  end

  def has_codes?
    return true unless code_list.new_record?

    @event.respond("You do not have any codes, #{@discord_username}.")
    false
  end

  def has_code?(system)
    return true if code_list.system_codes.key?(system)

    @event.respond("You do not have a code for '#{system}', #{@discord_username}.")
    false
  end
end
