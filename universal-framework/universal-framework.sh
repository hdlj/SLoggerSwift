lipo -create -output "SLoggerSwift" "Debug-iphonesimulator/SLoggerSwift.framework/SLoggerSwift" "Debug-iphoneos/SLoggerSwift.framework/SLoggerSwift"
cp -R Debug-iphoneos/SLoggerSwift.framework ./SLoggerSwift.framework
mv SLoggerSwift ./SLoggerSwift.framework/SLoggerSwift
