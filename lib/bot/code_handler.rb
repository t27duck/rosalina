# frozen_string_literal: true

class CodeHandler
  def initialize(event)
    @bot = event.bot
    @event = event
    @discord_id = event.user.id
    @discord_username = event.user.username
  end

  def process(command, arg1, arg2)
    case command
    when "view"
      display_codes(arg1, arg2)
    when "help"
      @event.respond(<<~TEXT)
        Code Service Commands:
        **%codes** - View your codes.
        **%codes view [username]** - View someone else's codes.
        **%codes add [service] [code]** - Adds a code for a service.
        **%codes remove [service]** - Removes the code stored for the given service.
        **%codes clear** - Removes all codes.
        Valid services: #{valid_systems.sort.join(' ')}
        Example: %codes add switch 1234-1234-1234
        Example: %codes view t27duck
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

  def display_codes(arg1, arg2)
    id = figure_out_id(arg1, arg2)
    return unless has_codes?(id)

    user = @bot.users[id.to_i]

    @event.channel.send_embed do |embed|
      embed.title = "#{user.username}'s game codes"
      embed.description = code_list(id).system_code_display
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: user.avatar_url)
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Use '%codes help' for more info")
    end
  end

  def figure_out_id(arg1, arg2)
    return @discord_id if arg1.blank?

    if arg1.match?(/\A<@!?.+>\z/)
      id = arg1.gsub(/\A<@!?/, '')
      id = id.gsub(/>\z/, '')
      return id
    else
      arg = [arg1, arg2].join(' ').strip
      id, user = @bot.users.detect { |id, user| user.username.downcase == arg.downcase }.to_a.flatten
      return id
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

    code_list(@discord_id).system_codes[system] = code
    code_list(@discord_id).save!
    @event.respond("Code for '#{system}' added")
  end

  def remove_code(system)
    system.downcase!
    return unless validate_system(system)
    return unless has_codes?(@discord_id)
    return unless has_code?(system, @discord_id)

    code_list(@discord_id).system_codes.delete(system)
    code_list(@discord_id).save!
    @event.respond("Code for '#{system}' removed!")
  end

  def code_list(id)
    @code_list ||= {}
    @code_list[id.to_i] ||= CodeList.where(discord_id: id).first_or_initialize
  end

  def validate_system(system)
    return true if valid_systems.include?(system)

    @event.respond("Invalid system '#{system}'")
    false
  end

  def has_codes?(id)
    return true unless code_list(id).new_record?

    @event.respond('No codes found')
    false
  end

  def has_code?(system, id)
    return true if code_list(id).system_codes.key?(system)

    @event.respond("You do not have a code for '#{system}', #{@discord_username}.")
    false
  end
end
