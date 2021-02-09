
def process
  log 'Copying block texture files'
  FileUtils.copy_entry block_textures_in_dir, mkdir_unless_exists(block_textures_out_dir)
  log 'Done copying'
end

def mkdir_unless_exists(dir)
  FileUtils.mkpath dir unless Dir.exists? dir
  dir
end