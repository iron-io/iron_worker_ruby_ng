def carrierwave_configure(aws_access_key, aws_secret_key, aws_bucket)
  CarrierWave.configure do |config|
    config.fog_credentials = {
      :provider             => 'AWS',
      :aws_access_key_id     => aws_access_key,
      :aws_secret_access_key => aws_secret_key
    }

    config.fog_directory = aws_bucket
  end
end
