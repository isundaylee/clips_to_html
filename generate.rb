#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'

require 'sqlite3'
require 'fileutils'
require 'liquid'
require 'erubis'

template = Erubis::Eruby.new File.read('template.html.erb')
out_path = File.expand_path 'output'

db_path = File.expand_path '~/Dropbox/Synced/Clips.db'
db = SQLite3::Database.open db_path

clips = db.prepare("SELECT * FROM clips").execute.to_a
days = clips.group_by { |c| DateTime.iso8601(c[1]).to_date }.to_a
weeks = days.group_by { |d| [d[0].year, d[0].strftime('%W').to_i] }

FileUtils.rm_rf out_path
FileUtils.mkdir_p out_path

weeks.each do |week, days|
  puts "Generating page for #{week}"

  days.each do |day|
    date = day[0]
    clips = day[1]

    readable = date.strftime('%A, %b %-d, %Y')
  end

  # html = Liquid::Template.parse(template).render 'week' => week, 'days' => days

  html = template.result(week: week, days: days)

  File.write(File.join(out_path, "#{week[0]} Week #{week[1]}.html"), html)
end