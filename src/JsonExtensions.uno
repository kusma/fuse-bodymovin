using Uno.Data.Json;

static class JsonExtensions
{
	public static float GetFloatMember(this JsonReader json, string name, float def)
	{
		var val = json[name];
		if (val == null || val.JsonDataType != JsonDataType.Number)
			return def;

		return (float)val.AsNumber();
	}

	public static int GetIntMember(this JsonReader json, string name, int def)
	{
		var val = json[name];
		if (val == null || val.JsonDataType != JsonDataType.Number)
			return def;

		return (int)val.AsNumber();
	}

	public static bool GetBoolMember(this JsonReader json, string name, bool def)
	{
		var val = json[name];
		if (val == null || val.JsonDataType != JsonDataType.Boolean)
			return def;

		return val.AsBool();
	}

	public static string GetStringMember(this JsonReader json, string name, string def = string.Empty)
	{
		var val = json[name];
		if (val == null || val.JsonDataType != JsonDataType.String)
			return def;

		return val.AsString();
	}

	public static JsonReader GetObjectMember(this JsonReader json, string name)
	{
		var val = json[name];
		if (val == null || val.JsonDataType != JsonDataType.Object)
			return null;

		return val;
	}

	public static JsonReader GetArrayMember(this JsonReader json, string name)
	{
		var val = json[name];
		if (val == null || val.JsonDataType != JsonDataType.Array)
			return null;

		return val;
	}
}
