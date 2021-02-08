require_relative 'datamorphsis'

Task.new do
  self.input_dir = $IN / "lang/"
  self.output_dir = $OUT / "text/"
  self.exec = 'converters/language'
end.run