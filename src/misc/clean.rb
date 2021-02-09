require 'fileutils'
def process
  log "Cleaning folder #{out_dir}"
  FileUtils.rm_rf("#{out_dir}/.", secure: true)
  log 'Done!'
end
