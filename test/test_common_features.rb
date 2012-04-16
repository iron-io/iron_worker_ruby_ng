require 'helpers'
require 'zip/zip'

class CommonFeaturesTest < IWNGTest

  def test_merge_file
    code = code_bundle('test') do
      merge_file('test', 'test/data/dir2')
      merge_worker('test/hello.rb')
    end

    Zip::ZipFile.open(code.create_zip) do |zip|
      assert zip.find_entry('test/data/dir2/test')
    end
  end

end
