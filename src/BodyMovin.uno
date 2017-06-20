using Uno;
using Uno.Data.Json;
using Uno.UX;

using Fuse;
using Fuse.Animations;
using Fuse.Controls;
using Fuse.Triggers;

public partial class BodyMovin : LayoutControl
{
	FileSource _fileSource;
	public FileSource File
	{
		get { return _fileSource; }
		set
		{
			_fileSource = value;
			LoadData();
		}
	}

	Timeline _timeline = new Timeline();

	public BodyMovin()
	{
		_timeline.PlayMode = PlayMode.Wrap;
		Children.Add(_timeline);
	}

	protected override void OnRooted()
	{
		base.OnRooted();
	}

	void LoadData()
	{
		var str = _fileSource.ReadAllText();
		try
		{
			LoadFromJson(JsonReader.Parse(str));
		}
		catch (Exception e)
		{
			debug_log "error: " + e.ToString();
		}
	}
}
