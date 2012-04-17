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

  def test_merge_dir_check
    assert_raise RuntimeError, "should check if merged dir exists" do
      code_bundle('test') do
        merge_dir('dir2', 'test/data')
      end
    end
  end

  def test_merge_dir
    code = code_bundle('test') do
      merge_dir('test/data/dir2', 'test/data')
      merge_worker('test/hello.rb')
    end

    Zip::ZipFile.open(code.create_zip) do |zip|
      assert zip.find_entry('test/data/dir2/test')
    end
  end

end
