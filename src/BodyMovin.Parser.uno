using Uno;
using Uno.Collections;
using Uno.Data.Json;
using Uno.UX;

using Fuse;
using Fuse.Animations;
using Fuse.Controls;

sealed class RotationDegreesProperty: Uno.UX.Property<float>
{
	[Uno.WeakReference] readonly Rotation _obj;

	public RotationDegreesProperty(Rotation obj, Selector name) :
		base(name)
	{
		_obj = obj;
	}

	public override PropertyObject Object { get { return _obj; } }
	public override float Get(PropertyObject obj) { return ((Rotation)obj).Degrees; }
	public override void Set(PropertyObject obj, float v, IPropertyListener origin) { ((Rotation)obj).Degrees = v; }
}

sealed class ScalingVectorProperty: Uno.UX.Property<float3>
{
	[Uno.WeakReference] readonly Scaling _obj;

	public ScalingVectorProperty(Scaling obj, Selector name) :
		base(name)
	{
		_obj = obj;
	}

	public override PropertyObject Object { get { return _obj; } }
	public override float3 Get(PropertyObject obj) { return ((Scaling)obj).Vector; }
	public override void Set(PropertyObject obj, float3 v, IPropertyListener origin) { ((Scaling)obj).Vector = v; }
}

sealed class TranslationXProperty: Uno.UX.Property<float>
{
	[Uno.WeakReference] readonly Translation _obj;

	public TranslationXProperty(Translation obj, Selector name) :
		base(name)
	{
		_obj = obj;
	}

	public override PropertyObject Object { get { return _obj; } }
	public override float Get(PropertyObject obj) { return ((Translation)obj).X; }
	public override void Set(PropertyObject obj, float v, IPropertyListener origin) { ((Translation)obj).X = v; }
}

sealed class TranslationYProperty: Uno.UX.Property<float>
{
	[Uno.WeakReference] readonly Translation _obj;

	public TranslationYProperty(Translation obj, Selector name) :
		base(name)
	{
		_obj = obj;
	}

	public override PropertyObject Object { get { return _obj; } }
	public override float Get(PropertyObject obj) { return ((Translation)obj).Y; }
	public override void Set(PropertyObject obj, float v, IPropertyListener origin) { ((Translation)obj).Y = v; }
}

sealed class TranslationXYProperty: Uno.UX.Property<float2>
{
	[Uno.WeakReference] readonly Translation _obj;

	public TranslationXYProperty(Translation obj, Selector name) :
		base(name)
	{
		_obj = obj;
	}

	public override PropertyObject Object { get { return _obj; } }
	public override float2 Get(PropertyObject obj) { return ((Translation)obj).XY; }
	public override void Set(PropertyObject obj, float2 v, IPropertyListener origin) { ((Translation)obj).XY = v; }
}

public partial class BodyMovin
{
	List<Panel> _layers = new List<Panel>();
	Panel LoadLayerFromJson(JsonReader json)
	{
		var layer = new Panel();

		var name = json.GetStringMember("nm");
		var refId = json.GetStringMember("refId");
		var layerId = json.GetIntMember("ind", -1);
		var layerType = json.GetIntMember("ty", -1);
		var parent = json.GetIntMember("parent", -1);

		var transform = json.GetObjectMember("ks");
		if (transform != null)
			LoadTransformFromJson(transform, layer);

		var shapes = json.GetArrayMember("shapes");
		if (shapes != null)
		{
			for (int i = 0; i < shapes.Count; ++i)
				LoadShapesFromJson(shapes[i], layer);
		}

		if (layerType == 1)
		{
			// solid
			var sw = json.GetIntMember("sw", 0);
			var sh = json.GetIntMember("sh", 0);
			var sc = Color.FromHex(json.GetStringMember("sc"));

			var rect = new Rectangle();
			rect.Width = sw;
			rect.Height = sh;
			rect.Color = sc;
			layer.Children.Add(rect);
		}

		_layers.Add(layer);
		Children.Add(layer);
		return layer;
	}

	Shape LoadEllipseFromJson(JsonReader json)
	{
		var p = json.GetObjectMember("p");
		if (p == null)
			throw new Exception("p should never be null!");
		var position = LoadAnimatableValue2(p);
		if (position.InitialValues[0] != 0 ||
		    position.InitialValues[1] != 0)
			debug_log "WARNING: non-default position on ellipse, not supported yet!";
		if (position.Keyframes != null)
			debug_log "WARNING: animated position on ellipse, not supported yet!";

		var s = json.GetObjectMember("s");
		if (s == null)
			throw new Exception("s should never be null!");
		var size = LoadAnimatableValue2(s);
		if (size.Keyframes != null)
			debug_log "WARNING: animated size on ellipse, not supported yet!";

		var ellipse = (size.Keyframes == null && size.InitialValues[0] == size.InitialValues[1]) ? (Shape)new Circle() : new Ellipse();
		// TODO: position
		ellipse.Width = size.InitialValues[0];
		ellipse.Height = size.InitialValues[1];
		return ellipse;
	}

	void LoadShapesFromJson(JsonReader json, Panel parent)
	{
		var type = json.GetStringMember("ty");
		var name = json.GetStringMember("nm");

		if (type == "gr")
		{
			var items = json.GetArrayMember("it");
			if (items == null)
				throw new Exception("items should never be null!");

			var group = new Panel();
			for (int i = 0; i < items.Count; ++i)
				LoadShapesFromJson(items[i], group);
			parent.Children.Add(group);
		}
		else if (type == "el")
		{
			var ellipse = LoadEllipseFromJson(json);

			ellipse.Color = float4(1, 0, 1, 1); // HACK!

			parent.Children.Add(ellipse);
		}
		else if (type == "fl")
		{
			debug_log "WARNING: ignoring fill!";
		}
		else if (type == "st")
		{
			debug_log "WARNING: ignoring stroke!";
		}
		else if (type == "tr")
		{
			LoadTransformFromJson(json, parent);
		}
		else
		{
			throw new Exception("unsupported shape-item type: " + type);
		}
	}

	class Keyframe
	{
		public readonly int Frame;
		public readonly float[] StartValues;
		public readonly float[] EndValues;

		public Keyframe(int frame, float[] startValues, float[] endValues)
		{
			Frame = frame;
			StartValues = startValues;
			EndValues = endValues;
		}

		static float4 ArrayToFloat4(float[] array)
		{
			switch (array.Length)
			{
				case 0: return float4(0, 0, 0, 0);
				case 1: return float4(array[0], array[0], array[0], array[0]);
				case 2: return float4(array[0], array[1], array[1], array[1]);
				case 3: return float4(array[0], array[1], array[2], array[2]);
			}
			return float4(array[0], array[1], array[2], array[3]);
		}

		public float4 GetStartValue()
		{
			if (StartValues == null)
				return float4(0, 0, 0, 0);
			return ArrayToFloat4(StartValues);
		}

		public float4 GetEndValue()
		{
			if (EndValues == null)
				return float4(0, 0, 0, 0);
			return ArrayToFloat4(EndValues);
		}
	}

	class AnimatableValue
	{
		public AnimatableValue(Keyframe[] keyframes, float[] initialValues)
		{
			if (initialValues == null)
				throw new ArgumentNullException(nameof(initialValues));

			Keyframes = keyframes;
			InitialValues = initialValues;
		}

		public readonly Keyframe[] Keyframes;
		public readonly float[] InitialValues;
	}

	static float[] LoadValueArray(JsonReader json)
	{
		var values = new float[json.Count];
		for (int i = 0; i < json.Count; ++i)
		{
			var v = json[i];
			if (v.JsonDataType != JsonDataType.Number)
				throw new Exception("Unexpected type: " + v.JsonDataType);
			values[i] = (float)v.AsNumber();
		}
		return values;
	}

	static Keyframe LoadKeyframe(JsonReader json)
	{
		var t = json.GetIntMember("t", -1);
		if (t < 0)
			throw new Exception("invalid time-stamp");

		var s = json.GetArrayMember("s");
		var startValues = s != null ? LoadValueArray(s) : null;

		var e = json.GetArrayMember("e");
		var endValues = e != null ? LoadValueArray(e) : null;

		return new Keyframe(t, startValues, endValues);
	}

	static Keyframe[] LoadKeyframes(JsonReader json)
	{
		var keys = json.GetArrayMember("k");
		if (keys == null)
			throw new Exception("unexpected type for keys: " + keys.JsonDataType );

		if (keys.Count < 1)
			throw new Exception("keys need at least one element");

		var keyframes = new List<Keyframe>();
		for (int i = 0; i < keys.Count; ++i)
		{
			var keyFrame = keys[i];
			if (keyFrame.JsonDataType != JsonDataType.Object)
				throw new Exception("keyFrame must be Object");

			keyframes.Add(LoadKeyframe(keyFrame));
		}

		return keyframes.ToArray();
	}

	AnimatableValue LoadAnimatableValue(JsonReader json)
	{
		var animated = json.GetIntMember("a", 0) != 0;
		if (animated)
		{
			var keyframes = LoadKeyframes(json);
			return new AnimatableValue(keyframes, keyframes[0].StartValues);
		}
		else
		{
			var keys = json["k"];
			if (keys.JsonDataType != JsonDataType.Number)
				throw new Exception("keys must be Value");

			return new AnimatableValue(null, new float[] { (float)keys.AsNumber() });
		}
	}

	AnimatableValue LoadAnimatableValue2(JsonReader json)
	{
		var animated = json.GetIntMember("a", 0) != 0;
		if (animated)
		{
			var keyframes = LoadKeyframes(json);
			return new AnimatableValue(keyframes, keyframes[0].StartValues);
		}
		else
		{
			var keys = json["k"];
			if (keys.JsonDataType != JsonDataType.Array)
				throw new Exception("keys must be Array");
			if (keys.Count < 2)
				throw new Exception("keys must be at least two component wide: " + keys.Count);

			return new AnimatableValue(null, new float[]
			{
				(float)keys[0].AsNumber(),
				(float)keys[1].AsNumber()
			});
		}
	}

	static Selector DegreesName = "Degrees";
	static Selector VectorName = "Vector";
	static Selector XName = "X";
	static Selector YName = "X";
	static Selector XYName = "XY";

	Change<T> ConvertAnimation<T>(Uno.UX.Property<T> property, AnimatableValue animation, float scale = 1.0f)
	{
		var change = new Change<T>(property);
		for (int i = 0; i < animation.Keyframes.Length - 1; ++i)
		{
			var startTime = animation.Keyframes[i].Frame / _frameRate;
			var startValue = animation.Keyframes[i].GetStartValue() * scale;
			change.Keyframes.Add(new Fuse.Animations.Keyframe()
			{
				Time = startTime,
				Value = startValue
			});

			var endTime = animation.Keyframes[i + 1].Frame / _frameRate;
			var endValue = animation.Keyframes[i].GetEndValue() * scale;
			change.Keyframes.Add(new Fuse.Animations.Keyframe()
			{
				Time = endTime,
				Value = endValue
			});
		}

		return change;
	}

	void LoadTransformFromJson(JsonReader json, Panel panel)
	{
		AnimatableValue anchor = null;
		var a = json.GetObjectMember("a");
		if (a != null)
		{
			anchor = LoadAnimatableValue2(a);
			var initial = float2(anchor.InitialValues[0], anchor.InitialValues[1]);
			var anchorPre = new Translation()
			{
				XY = initial
			};
			panel.Children.Add(anchorPre);
		}

		var p = json.GetObjectMember("p");
		if (p == null)
			throw new Exception("position should never be null!");

		if (p.GetBoolMember("s", false))
		{
			var x = LoadAnimatableValue(p.GetObjectMember("x"));
			var y = LoadAnimatableValue(p.GetObjectMember("y"));
			var initial = float2(x.InitialValues[0], y.InitialValues[0]);

			var translation = new Translation()
			{
				XY = initial
			};

			if (x.Keyframes != null)
			{
				var translationProperty = new TranslationXProperty(translation, XName);
				var change = ConvertAnimation(translationProperty, x);
				_timeline.Animators.Add(change);
			}

			if (y.Keyframes != null)
			{
				var translationProperty = new TranslationYProperty(translation, YName);
				var change = ConvertAnimation(translationProperty, y);
				_timeline.Animators.Add(change);
			}

			panel.Children.Add(translation);
		}
		else
		{
			var position = LoadAnimatableValue2(p);
			var initial = float2(position.InitialValues[0], position.InitialValues[0]);

			var translation = new Translation()
			{
				XY = initial
			};

			if (position.Keyframes != null)
			{
				var translationProperty = new TranslationXYProperty(translation, XYName);
				var change = ConvertAnimation(translationProperty, position);
				_timeline.Animators.Add(change);
			}

			panel.Children.Add(translation);
		}

		var s = json.GetObjectMember("s");
		if (s != null)
		{
			var scale = LoadAnimatableValue2(s);
			var initial = float2(scale.InitialValues[0], scale.InitialValues[0]) / 100.0f;

			var scaling = new Scaling()
			{
				Vector = float3(initial, 1.0f)
			};

			if (scale.Keyframes != null)
			{
				var scalingProperty = new ScalingVectorProperty(scaling, VectorName);
				var change = ConvertAnimation(scalingProperty, scale, 1.0f / 100);
				_timeline.Animators.Add(change);
			}

			panel.Children.Add(scaling);
		}

		var r = json.GetObjectMember("r");
		if (r != null)
		{
			var rot = LoadAnimatableValue(r);
			var initial = rot.InitialValues[0];

			var rotation = new Rotation()
			{
				Degrees = initial
			};

			if (rot.Keyframes != null)
			{
				var rotationProperty = new RotationDegreesProperty(rotation, DegreesName);
				var change = ConvertAnimation(rotationProperty, rot);
				_timeline.Animators.Add(change);
			}

			panel.Children.Add(rotation);
		}

		if (anchor != null)
		{
			var initial = float2(-anchor.InitialValues[0], -anchor.InitialValues[1]);
			var anchorPost = new Translation()
			{
				XY = initial
			};
			panel.Children.Add(anchorPost);
		}
	}

	float _frameRate;
	void LoadFromJson(JsonReader json)
	{
		var width = json.GetIntMember("w", -1);
		var height = json.GetIntMember("h", -1);

		var startFrame = json.GetIntMember("ip", 0);
		var endFrame = json.GetIntMember("op", 0);
		_frameRate = json.GetIntMember("fr", 30);

		var center = new Translation() {
			X = -width / 2,
			Y = -height / 2
		};
		Children.Add(center);

		// var assets = json.GetArrayMember("assets");
		var layers = json.GetArrayMember("layers");
		if (layers == null)
			throw new Exception("layers should never be null!");

		for (int i = 0; i < layers.Count; ++i)
			LoadLayerFromJson(layers[i]);
	}
}
