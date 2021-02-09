# frozen_string_literal: true

require 'json'
require 'fileutils'
require_relative 'common'

CATEGORY_CONVERSIONS = { 'block' => 'tile' }.freeze

def process
  unless Dir.exists? lang_dir
    log 'Language directory does not exist! Skipping...'
    return
  end

  inputs = Dir.children(lang_dir)

  if inputs.size <= 0
    log 'No language files found! Skipping...'
    return
  end

  FileUtils.mkpath text_dir unless Dir.exists? text_dir

  log "Processing language files: (#{inputs.size})"

  inputs.each do |input_fn|
    in_file_path = File.join lang_dir, input_fn
    in_file_rel_path = File.join lang_dir.rel, input_fn

    # determines the output file name
    out_file_base_path = input_fn.dup
    segments = out_file_base_path.delete_suffix('.json').split('_')
    segments.last.upcase!
    out_file_base_path = segments.join('_') + '.lang'
    out_file_path = File.join text_dir, out_file_base_path
    out_file_rel_path = File.join text_dir.rel, out_file_base_path

    in_file = File.open(in_file_path, 'r')
    out_file = File.open(out_file_path, 'w+')

    log "Processing #{in_file_rel_path} -> #{out_file_rel_path}"

    lang_json = JSON.parse(in_file.read)

    header = <<~HEADER
      # generated file ~ manual changes will be overwritten!
      # generated by datamorphsis v0.1.0
      # source file: #{in_file_rel_path}

    HEADER

    out_file.write header

    lang_json.each do |k, v|
      (category, ns, *rest) = k.split '.'

      # attempt to convert the category
      conv = CATEGORY_CONVERSIONS[category]
      category = conv unless conv.nil?

      out_file.write "#{category}.#{ns}:#{rest.join '.'}.name=#{v}\n"
    end
  end


  log 'Appending to languages.json'
  languages = inputs.map { |fn| fn.delete_suffix '.json' }
  File.write(File.join(text_dir, 'languages.json'), JSON.generate(languages))

  log 'Done processing language files'
end


