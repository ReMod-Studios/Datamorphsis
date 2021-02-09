# frozen_string_literal: true

require 'json'
require 'fileutils'

def process
  unless Dir.exists? block_model_dir
    log 'Block model directory not found! Skipping...'
    return
  end

  inputs = Dir.children(block_model_dir)

  if inputs.size <= 0
    log 'No block models found! Skipping...'
    return
  end


  FileUtils.mkpath(File.dirname(blocks_json)) unless File.exists? blocks_json

  log "Processing block models: (#{inputs.size})"

  blocks_data = {}
  if File.exist? blocks_json
    log 'Reading from existing blocks.json'
    blocks_data = JSON.parse(File.read(blocks_json))
  else
    log 'blocks.json not found; creating'
  end


  blocks_file = File.open blocks_json, mode: "w+"

  blocks_data.update(
    "__datamorphsis_comment": [
      "generated file - manual changes may be overwritten",
      "by datamorphsis v0.1.0"
    ],
    "format_version": [1, 1, 0]
  )

  inputs.each do |input_fn|
    in_file_path = File.join block_model_dir, input_fn

    id = Identifier.new(namespace, File.basename(input_fn, '.json'))

    log "Processing model (#{id})"
    block_data = {
      "sound": 'datamorphsis - cannot deduce from context!'
    }
    blocks_data[id] = block_data

    model_json = JSON.parse(File.read(in_file_path))

    block_data['textures'] = try_parse_model(model_json)
  end

  log 'Writing changes to blocks.json'
  blocks_file.write(JSON.pretty_generate(blocks_data))

  log 'Done processing block models'
  blocks_data
end

class Hash
  def keys?(keys)
    keys.all? { |key| self.key? key }
  end
end

def normalize(str)
  str.delete_prefix 'block/'
end

def try_parse_model(model_json)
  if model_json.empty?
    return # an empty model? you are weird that way
  end

  model_textures = model_json["textures"]
  model_textures&.transform_values! { |s| normalize(s) }

  # guesswork time
  if model_textures&.key? 'all'
    # cube_all?
    model_textures["all"]
  elsif model_textures&.keys? %w{end side}
    # cube_column?
    {
      "up": model_textures["end"],
      "down": model_textures["end"],
      "side": model_textures["side"]
    }
  elsif model_textures&.keys? %w{top bottom side}
    # cube_bottom_top?
    {
      "up": model_textures["top"],
      "down": model_textures["bottom"],
      "side": model_textures["side"]
    }
  elsif model_textures&.keys? %w{top side}
    # cube_top_side?
    # TODO is this the right format?
    {
      "up": model_textures["top"],
      "down": model_textures["side"],
      "side": model_textures["side"]
    }
  else
    {
      "__datamorphsis_error": "unrecognized model format!"
    }
  end
end

