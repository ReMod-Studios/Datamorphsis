# frozen_string_literal: true

require 'json'
require 'fileutils'

def process
  unless Dir.exists? item_model_dir
    log 'Item model directory not found! Skipping...'
    return
  end

  inputs = Dir.children(item_model_dir)

  if inputs.size <= 0
    log 'No item models found! Skipping...'
    return
  end

  FileUtils.mkpath(File.dirname(item_texture_json)) unless Dir.exists? item_texture_json

  log "Processing item models: (#{inputs.size})"

  texture_data = {}
  item_texture_data = {
    "__datamorphsis_comment": [
      "generated file - manual changes may be overwritten",
      "by datamorphsis v0.1.0"
    ],
    "resource_pack_name": "datamorphsis_generated",
    "texture_name": "atlas.items",
    "texture_data": texture_data
  }

  inputs.each do |input_fn|
    in_abs_path = File.join item_model_dir, input_fn

    id = Identifier.new(namespace, File.basename(input_fn, '.json'))

    log "Processing model (#{id})"
    model_json = JSON.parse(File.read(in_abs_path))
    parent = model_json["parent"]&.to_id

    #TODO support other parents
    if parent == "item/generated".to_id
      texture_data[id.path] = {
        "textures": "textures/items/#{id.path}"
      }
    end
  end

  log "Writing to item_texture.json"
  File.write(item_texture_json, JSON.pretty_generate(item_texture_data))

  log 'Done processing item models'
end