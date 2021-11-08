# frozen_string_literal: true

SPECIAL = { 'SPC' => ' ' }.freeze

characters = File.read('font').lines.map do |l|
  c, *segments = l.split(' ')

  puts({ c: c, segments: segments })

  [SPECIAL.fetch(c, c), segments.map { |s| 1 << (s.to_i - 1) }.reduce(0) { |x, y| x | y }]
end

font = <<~FONT
  let sevenSegmentFont: [Character: UInt32] = [
  #{characters.map { |c, v| "  \"#{c}\": #{v}," }.join("\n")}
  ]
FONT

File.write('SegmentedFont.swift', font)
