require_relative 'src/datamorphsis'

datamorphsis 'minecraft' do
  <<~HERE
  run_task('clean') { exec 'misc/clean' }
  run_task('copy_assets') do
    exec 'workflow/copy_assets'
    inputs(
      block_textures_in_dir: "textures/block/"
    )
    outputs(
      block_textures_out_dir: "textures/blocks/"
    )
  end
  HERE

  run_task 'language' do
    exec 'converters/language'
    inputs(
      lang_dir: "lang/"
    )
    outputs(
      text_dir: "text/"
    )
  end

  run_task 'item_models' do
    exec 'converters/item_models'
    inputs(
      item_model_dir: 'models/item'
    )
    outputs(
      item_texture_json: "textures/item_texture.json"
    )
  end

  block_models = task 'block_models' do
    exec 'converters/block_models'
    inputs(
      block_model_dir: 'models/block'
    )
    outputs(
      blocks_json: "blocks.json"
    )
  end

  block_textures = task 'block_textures' do
    exec 'converters/block_textures'
    outputs(
      blocks_json: "blocks.json",
      flipbook_json: "textures/flipbook_textures.json",
      terrain_texture_json: "textures/terrain_texture.json"
    )
  end
  blocks_data = block_models.run
  block_textures.run(blocks_data)
end
