class SampleUploader < CarrierWave::Uploader::Base
  storage :fog
end
