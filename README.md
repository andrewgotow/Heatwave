# Heatwave
![](https://github.com/andrewgotow/Heatwave/blob/master/screenshots/flame_demo_gif.gif)

Heatwave is a simple post-processing effect for the Unity game engine, designed to add small-scale distortion and refraction effects to your scenes. Using a two-camera system, distortions can be caused by particle effects, fullscreen overlays, GUI elements, and whatever else you might want!
Heatwave is designed to be simple and efficient, sacrificing accuracy for incredible performance, and ease of use. Setup is automatic, and configuring your effects takes only a few minutes.

# How it works.
Heatwave is based loosely on a [presentation](https://www.youtube.com/watch?v=0k-lmDPLwxc) given at Unite 2007, and builds a fullscreen normal map based on specific rendered layers in the scene. This normal map is then used to calculate light refractions, as though the entire scene were being viewed through a thick pane of glass. This means that the cost of computation is fixed, and additional refraction source will not significantly impact performance. It also allows the normal buffer to be written by mulitple different sources, meaning you can combine multiple different sources to produce interesting outputs.
The downside of this solution is that the effect is not *actually* calculating refractions. Complex lensing effects are not feasible, and interesting optical phenomena such as refracting light onto otherwise occluded surfaces simply will not work. This effect is designed only to "look right", rather than simulate optics.

# How to use it.
Heatwave is incredibly easy to use. Create a scene, and attach the Heatwave image effect script to your camera. With this script attached, any particle effects using the "Distortion Source" shader will be rendered into the normal buffer. Other objects can work, though particles tend to work best. These objects should be colored like a traditional normal map, and are alpha blended into the buffer. That's all there is to it!
