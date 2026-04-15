# Spatial Violin

A spatial computing app for Apple Vision Pro that uses hand tracking to place an interactive 3D violin model on your left arm in a mixed reality environment.

## Features

- **Hand Tracking**: Real-time hand gesture recognition using ARKit's hand tracking API
- **3D Violin Model**: A detailed violin model positioned and oriented based on your arm
- **Immersive Experience**: Mixed reality view that blends digital and physical worlds
- **Customizable Positioning**:
  - Adjust violin scale for proper sizing
  - Control arm offset to position the violin along your forearm
  - Fine-tune rotation angles (X, Y, Z) for perfect alignment
- **Fallback Rendering**: Automatic fallback to a placeholder box if the 3D model fails to load

## Architecture

### Core Components

**Spatial_ViolinApp.swift**
- Main app entry point
- Sets up the window group and immersive space
- Manages immersion style (.mixed)

**ContentView.swift**
- User interface for the app
- Controls for starting/stopping the violin experience
- Sliders for adjusting scale, arm offset, and rotation corrections
- Real-time value display

**ViolinImmersiveView.swift**
- Handles the immersive 3D environment
- Loads the violin USDZ model
- Implements hand tracking via ARKit
- Calculates violin placement based on hand skeleton data
- Applies user-defined transformations

**AppModel.swift**
- Observable model for shared state
- Contains user-configurable parameters:
  - `violinScale`: Model size (0.001 to 0.5)
  - `armOffset`: Distance along the forearm (0.05 to 0.6 meters)
  - `rotationX/Y/Z`: Fine-tuning angles for alignment

## How It Works

1. **Launch** the app and see the Spatial Violin interface
2. **Tap "Start Playing"** to enter the immersive space
3. **Raise your left arm** - the app uses hand tracking to detect your hand
4. **The violin appears** on your forearm, aligned with your arm's orientation
5. **Use the sliders** to adjust:
   - Scale if the violin is too large or small
   - Arm offset to position it correctly along your arm
   - Rotation angles to fine-tune alignment
6. **Tap "Stop"** to exit the immersive space

## Technical Details

### Hand Tracking
The app uses ARKit's `HandTrackingProvider` to track your left hand in real-time. Key joints used:
- **Wrist**: Reference point for placing the violin
- **Middle finger metacarpal**: Used to determine forearm direction

### Spatial Calculation
The violin's position and orientation are calculated using:
- Forearm direction vector (from fingers toward elbow)
- Palm-facing direction (Y-axis of wrist transform)
- Orthogonal basis construction for proper alignment
- Quaternion-based rotation for smooth transformations

### Rotation Correction
Fine-grained rotation is applied via three independent axes:
- **X-axis**: Pitch adjustment
- **Y-axis**: Yaw adjustment  
- **Z-axis**: Roll adjustment

## Requirements

- Apple Vision Pro or compatible spatial computing device
- visionOS 2.0 or later
- Xcode 16 or later
- Swift 5.9 or later

## Building and Running

1. Open `Spatial Violin.xcodeproj` in Xcode
2. Select the target device (Vision Pro)
3. Build and run (⌘R)

## Assets

- `violin.usdz`: 3D violin model file (place in Assets.xcassets)
- The app includes a brown placeholder box as fallback if the model fails to load

## Known Limitations

- Supports left arm tracking only
- Requires hand to be visible in the Vision Pro camera
- Best results with clear hand visibility and natural arm position

## Future Enhancements

- Support for right arm tracking
- Multiple instrument models
- Audio simulation or integration
- Recording and playback of arm movements
- Multi-user synchronized experiences

## Author

Adrian Emmanuel Faz Mercado

## License

[License to be determined]
