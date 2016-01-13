# -*- coding: utf-8 -*-
# encoding: UTF-8

require 'cgi'
require 'systemu'
require 'slack'
Slack.configure {|config| config.token = ENV["TOKEN"] }
client = Slack.realtime

channelID = 'C04NR5FEY' # #shell

def tooLong2Fuck(str)
  if str == nil
    return ""
  end
  if str.length > 5000
    return ":fuck: too long :fuck:"
  end
  return str
end

def getName(str)
  File.open('id2name') do |file|
    file.each_line do |id2name|
      id = id2name[0,9]
      name = id2name[10,id2name.size]
      if str == id
        return name.chomp
      end
    end
  end
  return str
end

def shell(str)
  m = /^\$(.*)/u.match(str)
  if m == nil
    return nil
  end
  cmd = m[1]
  begin
    io = IO.popen(cmd, "r+")
    io.close_write
    ret = ""
    tmp = io.gets
    while tmp != nil do
      ret += tmp
      tmp = io.gets
    end
    return ret
  rescue
    return "No such file or directory -  " + cmd
  end
end

def shell2(str)
  m = /^\$(.*)/u.match(str)
  if m == nil
    return nil
  end
  cmd = m[1]
  status, stdout, stderr = systemu cmd
  ret = stdout + stderr
  if (ret.lines.count <= 10) 
    return ret
  else 
    split = ret.lines.take(10)
    result = ""
    split.each do |sp|
      result += sp
    end
    result += "-- and more --"
    return result
  end
  return ret
end


client.on :hello do
  puts 'Successfully connected.'
end

Thread.abort_on_exception=true

client.on :message do |data|
  if data['channel'] == channelID && data['subtype'] != 'bot_message' && data['user'] != "USLACKBOT"
    Thread.new do 
      puts "<" + getName(data['user']) + ">  " + CGI.unescapeHTML(data['text'])
      ret = shell2(CGI.unescapeHTML(data['text']))
      ret2 = "[" + getName(data['user'].force_encoding('ascii-8bit')) + "] : " + data['text'].force_encoding('ascii-8bit') + "\n" + tooLong2Fuck(ret)
      #puts "\t" + ret
      if ret != nil
        params = {
          channel: data['channel'],
          username: "shell",
          text: ret2,
          icon_emoji: ":shell2:"
        } 
        Slack.chat_postMessage params
      end
    end
  end
end

client.start
