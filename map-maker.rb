#!/usr/local/bin/ruby

require 'google-map-stitch'

puts 'ARGV.length ' << String(ARGV.length)
puts 'map-maker.rb ' << String(ARGV[0])

if ARGV.length != 1 && ARGV.length != 5
  puts 'Usage: map-maker.rb <zoomLevel> [startX] [endX] [startY] [endY]'
  exit 1
end

if ARGV.length == 1
  # entire map
  engine = GMS::Engine.new({:zoomLevel=>Integer(ARGV[0])})
else
  # map section
  engine = GMS::Engine.new({
    :startX => Integer(ARGV[1]),
    :endX => Integer(ARGV[2]),
    :startY => Integer(ARGV[3]),
    :endY => Integer(ARGV[4]),
    :zoomLevel => Integer(ARGV[0])
  })
end

downloader = GMS::Downloader.new(engine.tiles, 'tiles_folder')
downloader.process

stitcher = GMS::Stitcher.new('tiles_folder', '/tmp/map.png')
stitcher.process
