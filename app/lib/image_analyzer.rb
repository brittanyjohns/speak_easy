class ImageAnalyzer < ActiveStorage::Analyzer::ImageAnalyzer::ImageMagick
  def metadata
    read_image do |image|
      puts "Reading image: #{image.inspect}"
      if rotated_image?(image)
        { width: image.height, height: image.width, opaque: opaque?(image) }.compact
      else
        { width: image.width, height: image.height, opaque: opaque?(image) }.compact
      end
    end
  end

  private

  def opaque?(image)
    return true unless image.has_alpha?
    image[image.bands - 1].min == 255
  rescue ::Vips::Error
    false
  end
end
