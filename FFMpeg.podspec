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

	s.requires_arc = true
	s.source = { :git => 'git@github.com:666tos/FFMpeg.git', :tag => s.version.to_s }
    s.libraries = 'c++', 'z', 'bz2', 'iconv'
    s.preserve_paths = "ffmpeg"

 	s.subspec "iOS" do |sp|
		sp.ios.deployment_target = "9.0"
	    sp.private_header_files = "ffmpeg/include/**/*.h"
	    sp.header_mappings_dir = "ffmpeg/include"
	    sp.vendored_libraries = "ffmpeg/ios/*.a"

        # disallow i386 simulator builds, which are only happening when min deployment target is below 10.0
        sp.xcconfig = {
            'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64',
            'VALID_ARCHS[sdk=iphoneos*]' => 'arm64 armv7',
        }
	end

 	s.subspec "tvOS" do |sp|
		sp.tvos.deployment_target = "10.2"
	    sp.private_header_files = "ffmpeg/include/**/*.h"
	    sp.header_mappings_dir = "ffmpeg/include"
	    sp.vendored_libraries = "ffmpeg/tvos/*.a"
	end

end
