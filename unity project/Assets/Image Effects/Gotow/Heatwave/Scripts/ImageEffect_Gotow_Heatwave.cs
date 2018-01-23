using UnityEngine;

// Copyright (c) 2015, Andrew Gotow.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
[AddComponentMenu("Image Effects/Gotow/Heatwave")]
public class ImageEffect_Gotow_Heatwave : MonoBehaviour {

	// Keep a reference to the "primary" camera, that this image effect is being applied to.
	public Camera camera;
	
	// Keep a reference to the camera used to render the distortion normal map.
	[SerializeField,HideInInspector]
	private Camera _normalCamera;

	// Also maintain a reference to the post effect material.
	[SerializeField,HideInInspector]
	private Material _postEffectMaterial;

	[Header("Configuration")]
	// Allow the user to configure the layer used for distortion.
	public LayerMask normalMask;

	// The magnitude of the distortion. This probably shouldn't be above 1, but
	// some people might want to try something crazy.
	public float strength = 0.1f;

#if UNITY_EDITOR
	void Reset()
	{
		// Populate the default reference to the camera attached to this gameObject.
		camera = gameObject.GetComponent<Camera>();
	}
#endif

	// This function is called when the script is enabled, basically when it is
	// turned on in the editor, and when the game starts running.
	void OnEnable () {
		// Now, find or create our normal map camera. This will either search for a
		// pre-existing camera, or will create a new one, and configure it. We don't
		// want to create a new one every time the game starts, because this could
		// potentially be a costly operation.
		CreateNormalCamera();
		
		//Need to set the aspect ratio regardless of whether the normalCamera is created 
		// in the previous function or if it already existed
		_normalCamera.aspect = camera.aspect;

		// Build a render texture for the normal map camera. This lets us change the
		// resolution of our camera, and eliminate the unnecessary depth buffer, as
		// well as allows the render target to be mapped to a shader input.
		_normalCamera.targetTexture = new RenderTexture(
			(int)_normalCamera.pixelWidth, 		// width
			(int)_normalCamera.pixelHeight, 	// height
			0,									// depth
			RenderTextureFormat.ARGBHalf ); 	// format

		// Construct the post-effect shader here. This will be used when the scene
		// is rendered to apply a fullscreen effect.
		Shader postShader = Shader.Find( "Hidden/ImageEffects/Gotow/HeatDistortion" );
		_postEffectMaterial = new Material( postShader );
		_postEffectMaterial.SetTexture( "_DistortionTex", _normalCamera.targetTexture );
	}

	// When the script is removed, or the camera is destroyed, this is called.
	void OnDisable () {
		// get rid of the existing camera object if we've got one. We don't want to
		// pollute the user's hierarchy, especially not with cameras!
		if (_normalCamera != null) {
			GameObject.DestroyImmediate( _normalCamera.gameObject );
		}
	}

	// Fetches an existing camera in the hierarchy, or creates a new one.
	private void CreateNormalCamera () {
		// if we've already got a distortion camera, then just return immediately.
		if ( camera == null || _normalCamera != null) 
			return;

		// if we're still here, then we've got to create a camera ourselves, and add it
		// to the scene. First, construct a GameObject with our known name.
		GameObject obj = new GameObject( "ImageEffect_Gotow_HeatDistortion_Camera" );

		// set it to be uneditable, and invisible in the scene hierarchy.
		// it can be recreated later if we need it, and it will confuse the user to have
		// another camera floating around.
		obj.hideFlags = HideFlags.NotEditable | HideFlags.HideAndDontSave;
		
		// Set its transform to this script's transform, so that it will always follow
		// the camera we're putting the image effect on.
		obj.transform.SetParent(camera.transform);
		obj.transform.position = this.transform.position;
		obj.transform.rotation = this.transform.rotation;

		// Now, attach a camera component.
		_normalCamera = obj.AddComponent<Camera>();

		// set its projection matrix to match that of our main camera. This way, we
		// can always be sure that the cameras line up properly.
		_normalCamera.CopyFrom(camera);

		// Set the camera to clear to a normal-neutral background.
		_normalCamera.clearFlags = CameraClearFlags.SolidColor;
		_normalCamera.backgroundColor = new Color( 0.5f, 0.5f, 0.5f );
		_normalCamera.cullingMask = normalMask;

		// Lastly, set up the replacement shader. We want only our defining particle
		// effects to render into the distortion normal buffer, everything else in the
		// scene will use a depth-only shader, so that the particles can be occluded.
		_normalCamera.SetReplacementShader( Shader.Find( "Hidden/ImageEffects/Gotow/DistortionMapReplacement" ), "RenderType" );
	}

	// Lastly, when the scene is rendered, assign the shader's strength property,
	// which may have changed since the shader was constructed, and apply the effect.
  	void OnRenderImage(RenderTexture src, RenderTexture dest) {
		_postEffectMaterial.SetFloat( "_Strength", strength );
    	Graphics.Blit(src, dest, _postEffectMaterial);
  	}
}
