# -*- coding: utf-8 -*-

require "slack"
require "cgi"
require "pp"
require "open3"

BOT_NAME = "shell"
ICON_EMOJI = ":shell2:"
channelID = 'C04NR5FEY' # #shell
Slack.configure {|config| config.token = ENV["TOKEN"] }

p Slack.auth_test
client = Slack.realtime

$list = Slack.users_list["members"]

def id2user(id)
  ( $list.find{|n|n["id"] == id} || {"name" => id} )["name"]
end

def postTo(text, chan)
  Slack.chat_postMessage text: text, channel: chan, username:BOT_NAME, icon_emoji: ICON_EMOJI
end

def validMsg(data, chan)
  if data["channel"] == chan &&
     data['subtype'] != 'bot_message'
    yield id2user(data["user"]), data["text"], data
  end
end

def execCmd(cmd, inText = nil)
  begin
    Open3.popen2e(cmd+"\n"){|stdin, stdout| # "\n" makes always cmd interpreted in shell
      unless stdin.nil?
        stdin.puts inText
        stdin.close
      end
      raw = stdout.read(1000)&.force_encoding("UTF-8")
      if raw.nil?
        "-- empty --"
      elsif raw.split("\n").size > 20
        raw.split("\n")[0..20].join("\n") + "\n-- too long --"
      elsif !stdout.eof?
        raw + "\n-- too large --"
      else
        raw
      end
    }
  rescue
    "-- ERROR : #{$!.to_s} --"
  end
end

client.on :hello do
  puts "Successfully connected!"
  postTo "シェルたんは新しい命を手に入れた!", channelID
end

Thread.abort_on_exception=true
client.on :message do |data|
  validMsg(data, channelID) do |name, text, data|
    rawText = CGI.unescapeHTML(text)
    Thread.new do
      puts "<#{name}> #{rawText}"
      if m = rawText.match(/^\$(.*)/)
        cmd = m[1]
        result = execCmd(cmd)
        postTo "[#{name}] $#{cmd}\n#{result}", channelID
      elsif m = rawText.match(/^\#(.*)/)
        cmd = m[1]
        result = execCmd("zsh", cmd)
        postTo "[#{name}] ##{cmd}\n#{result}", channelID
      end
    end
  end
end

client.start
