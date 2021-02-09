require 'set'

def process(blocks_data)
  unless File.exists? blocks_json
    log 'blocks.json not found! Skipping...'
    return
  end

  FileUtils.mkpath(File.dirname(terrain_texture_json)) unless File.exists? terrain_texture_json

  terrain_texture_data = {}
  if File.exists? terrain_texture_json
    log 'Reading from existing terrain_texture.json'
    terrain_texture_data = JSON.parse(File.read(terrain_texture_json))
  else
    log 'terrain_texture.json not found; creating'
  end

  terrain_texture_file = File.open terrain_texture_json, mode: "w+"

  texture_data = {}

  terrain_texture_data.update(
    "_comment": "generated file - do not edit | by datamorphsis v0.1.0",
    "resource_pack_name": "datamorphsis_generated",
    "texture_name": "atlas.terrain",
    "padding": 8,
    "num_mip_levels": 4,
    "texture_data": texture_data
  )

  textures = Set.new

  blocks_data.each do |k, v|
    p k, v
    if v.is_a? Hash and v.key? "textures"
      tex = v["textures"]
      if tex.is_a? Hash
        textures += tex.values
      elsif tex.is_a? String
        textures.add tex
      end
    end
  end

  textures.each do |t|# tbh i dont know where it came from
    texture_data[t] = {
      "textures": [
        {
          "path": "textures/blocks/#{t}"
        }
      ]
    }
  end

  log 'Writing changes to terrain_texture.json'
  terrain_texture_file.write(JSON.pretty_generate(terrain_texture_data))





















  <<~HAHA
    

  
    # generate texture definitions from references
    #TODO this is cursed
    if block_texture.is_a? String
      texture_data[block_texture] = {
        "textures": "textures/blocks/{block_texture}"
      }
    elsif block_texture.is_a? Hash
      block_texture.each_value { |v|
        texture_data[v] = {
          "textures": "textures/blocks/{v}"
        }
      }
    end
  
    log 'Writing to terrain_texture.json'
    terrain_texture_file.write(JSON.pretty_generate(terrain_texture_data))
  HAHA
  log 'Done processing block textures'
end