# react-native-audio-routes-events

## Getting started

`$ npm install react-native-audio-routes-events --save`

### Mostly automatic installation

`$ react-native link react-native-audio-routes-events`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-audio-routes-events` and add `RNAudioRoutesEvents.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNAudioRoutesEvents.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainApplication.java`
  - Add `import com.reactlibrary.RNAudioRoutesEventsPackage;` to the imports at the top of the file
  - Add `new RNAudioRoutesEventsPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-audio-routes-events'
  	project(':react-native-audio-routes-events').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-audio-routes-events/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-audio-routes-events')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNAudioRoutesEvents.sln` in `node_modules/react-native-audio-routes-events/windows/RNAudioRoutesEvents.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Audio.Routes.Events.RNAudioRoutesEvents;` to the usings at the top of the file
  - Add `new RNAudioRoutesEventsPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNAudioRoutesEvents from 'react-native-audio-routes-events';

// TODO: What to do with the module?
RNAudioRoutesEvents;
```
  