
Pod::Spec.new do |s|

  s.name         = "SLoggerSwift"
  s.version      = "1.0.1"
  s.summary      = "logging framework based on XCGLogger developed by Dave Wood, Cerebral Gardens"

  s.description  = <<-DESC
                   SLoggerSwift is a logging framework based on XCGLogger developed by Dave Wood, Cerebral Gardens
                   With this framework, log can be send to a server as a JSON object
                   It is developed in  Swift
                   DESC

  s.homepage     = "https://github.com/hdlj/SLoggerSwift"

  s.license      = { :type => "MIT", :file => "https://github.com/hdlj/SLoggerSwift/blob/master/LICENSE" }


  s.author             = { "Hubert  de Taffanel De La Jonquiere" => "h.delajonquiere@gmail.com" }

  s.platform     = :ios
  s.platform     = :ios, "8.3"

  s.source       = { :git => "https://github.com/hdlj/SLoggerSwift", :tag => "master" }

  s.source_files  = "SLoggerSwift/universal-framework/SLoggerSwift.framework"

  s.requires_arc = true

end
