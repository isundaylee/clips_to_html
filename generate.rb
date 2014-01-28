#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'

require 'sqlite3'
require 'fileutils'
require 'liquid'
require 'erubis'
require 'logger'

require_relative 'config'
require_relative 'multi_io'
require_relative 'clip'
require_relative 'screenshot'

log_path = CONFIG[:log_path]
logger = Logger.new MultiIO.new(STDOUT, File.open(log_path, 'a'))

template = Erubis::Eruby.new File.read('assets/template.html.erb')
index_template = Erubis::Eruby.new File.read('assets/index.html.erb')
out_path = CONFIG[:output_path]

db_path = CONFIG[:db_path]
db = SQLite3::Database.open db_path

checksum_path = File.join out_path, '.checksum'
old_checksum = File.read(checksum_path).strip if File.exists?(checksum_path)
new_checksum = Digest::SHA2.hexdigest(File.read(db_path))

if new_checksum == old_checksum
  logger.info "Not changed since last generation. Exiting. "
  exit
else
  clips_rec = db.prepare("SELECT * FROM clips").execute.to_a

  clips = clips_rec.map { |rec| Clip.new DateTime.iso8601(rec[1]), rec[2] }
  screenshots = CONFIG[:screenshot_path].nil? ?
    [] :
    Dir[File.join(CONFIG[:screenshot_path], '*')].map { |ss| Screenshot.new DateTime.parse(File.mtime(ss).to_s), ss }
  miscs = CONFIG[:misc_pictures_path].nil? ?
    [] :
    Dir[File.join(CONFIG[:misc_pictures_path], '*')].map { |mp| Screenshot.new DateTime.parse(File.mtime(mp).to_s), mp }

  items = clips + screenshots + miscs
  items.sort_by! { |i| i.datetime }

  days = items.group_by { |c| c.datetime.to_date }.to_a
  weeks = days.group_by { |d| [d[0].year, d[0].strftime('%W').to_i] }
  years = weeks.keys.group_by { |w| w[0] }

  FileUtils.rm_rf out_path
  FileUtils.mkdir_p out_path

  logger.info "Generating index path"

  File.write(File.join(out_path, "index.html"), index_template.result(years: years))

  weeks.each do |week, days|
    logger.info "Generating page for #{week}"

    html = template.result(week: week, days: days)

    File.write(File.join(out_path, "#{week[0]} Week #{week[1].to_s.rjust(2, '0')}.html"), html)
  end

  File.write(checksum_path, new_checksum)
end

