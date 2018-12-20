Pod::Spec.new do |s|
	s.name = "FFMpeg"
	s.version = "0.1"
	s.summary = "FFMpeg library"
	s.description = <<-DESC
		FFMpeg library
		DESC
	s.homepage = "https://github.com/666tos/FFMpeg"
	s.license = "MIT"
	s.author = { "Nikita" => "nikita@splendo.com" }
	s.ios.deployment_target = "10.0"
	s.requires_arc = true

	s.source = { :git => 'git@github.com:666tos/FFMpeg.git', :tag => s.version.to_s }
    
    s.libraries = 'c++', 'z', 'bz2', 'iconv'
    s.private_header_files = "ffmpeg/include/**/*.h"
    s.header_mappings_dir = "ffmpeg/include"
    s.vendored_libraries = "ffmpeg/ios/**/*.a"
    s.preserve_paths = "ffmpeg"
end
