# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def shared_pods
    use_frameworks!
    
    pod 'Firebase/Core'
    pod 'Firebase/Database'
    pod 'Firebase/Messaging'
    pod 'Firebase/Auth'
end

target 'house' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for house
  shared_pods
  pod 'FirebaseUI/Auth'
  pod 'FirebaseUI/Facebook'
  pod 'SwipeCellKit'
  pod 'Eureka'
  pod 'IQKeyboardManagerSwift'
  pod 'SwiftLint'

end

target 'HousePalsCore' do
    shared_pods
end
