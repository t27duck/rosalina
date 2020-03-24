# frozen_string_literal: true

module SayingsContainer
  extend Discordrb::Commands::CommandContainer

  command :story do |event|
    event.respond("It's called The Ugly Barnacle... Once, there was an ugly barnacle. He was so ugly that everyone died. The end.")
  end

  command :legend do |event|
    event.respond(<<~TXT)
    Disturb not the harmony of fire, ice or lightning
    Lest these titans wreck destruction upon the world in which they clash
    Though the water's great guardian shall rise to quell the fighting
    Alone its song will fail, thus the earth shall turn to ash
    Oh, the chosen one
    Into thine hands bring together all three
    The treasures combined tame the beast of the sea
    From the trio of islands ancient spheres shall you take
    For between life and death, all the difference you make
    Oh, the chosen one
    Climb to the shrine to right what is wrong
    And the world will be healed by the guardian's song
    Oh, the chosen one
    TXT
  end

  command :song do |event|
    event.respond("Let's gather 'round the chatroom and sing our chatroom song. Our C-H-A-T-R-O-O-M song. And if you don't think that we can sing it faster then you're wrong But it'll help if you just sing along!")
  end
end
