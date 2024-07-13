extends Control
var path: String = "/"
var prevpath: String = "/"
var splittenpath: Array = path.split("/", false)
var movinglist = false
var movey = 0.0
var STOP = false # File Movement
var STOP2 = false # Editors Animation
var prevselection = []

# Lerp system
var updatepos = false
var updateinitpos = 0.0
var updateendpos = 0.0
var updateobject: Object
var updatefactor = 10.0
var updatecounter = 0.0


var clicking = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed: clicking = true
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed: clicking = false
	
	if $Actions/HSlider.value_changed:
		$ObjList.fixed_icon_size = Vector2($Actions/HSlider.value, $Actions/HSlider.value)
		
	if $Actions/CheckButton.value_changed:
		if $Actions/CheckButton.value == 2:
			$ObjList.icon_mode = $ObjList.ICON_MODE_TOP
			$ObjList.max_columns = 50
		elif $Actions/CheckButton.value == 1:
			$ObjList.icon_mode = $ObjList.ICON_MODE_LEFT
			$ObjList.max_columns = 50
		elif $Actions/CheckButton.value == 0:
			$ObjList.icon_mode = $ObjList.ICON_MODE_LEFT
			$ObjList.max_columns = 1
			
	if $Actions/Button5.button_pressed and not STOP2:
		showeditor(null)
		
	if $Go.button_pressed:
		path = $Path.text
		if not path.ends_with("/"): path += "/"
		fetchfolder(path)
	
	if $Actions/AddFoldr.button_pressed:
		DirAccess.make_dir_absolute(path + "test")
		fetchfolder(path)
		
	if $Path/Popup/Close.button_pressed:
		$Path.text = path
		get_tree().create_tween().set_ease(Tween.EASE_IN).tween_property($Path/Popup, "position:y", -136.0, 0.5).set_trans(Tween.TRANS_BACK)
		
	if $Direction.value_changed:
		if $Direction.value > 0.0:
			$TextureRect2.modulate = Color(0.0, 0.5 * $Direction.value, 1.0 * $Direction.value)
			$TextureRect2.position.x = 48.0 + $Direction.value * 16
			$TextureRect.position.x = 24.0
			$TextureRect.modulate = Color(0.0, 0.0, 0.0)
		else:
			$TextureRect.modulate = Color(0.0, 0.5 * -$Direction.value, 1.0 * -$Direction.value)
			$TextureRect.position.x = 24.0 + $Direction.value * 16
			$TextureRect2.position.x = 48.0
			$TextureRect2.modulate = Color(0.0, 0.0, 0.0)
			
			
	if $Direction.drag_ended and not clicking:
		if $Direction.value < -0.25:
			prevpath = path
			splittenpath.pop_back()
			
			if OS.get_name() == "Android": path = "/".join(splittenpath) + "/"
			else: path = "/" + "/".join(splittenpath) + "/"
			
			fetchfolder(path)
		elif $Direction.value > 0.25 and prevpath != path:
			path = prevpath
			fetchfolder(path)
		$Direction.value = 0.0
	
	
	if $ObjList.item_clicked and $ObjList.get_selected_items().size() > 0 and not STOP:
		var temp = $ObjList.get_item_text($ObjList.get_selected_items()[0])
		if DirAccess.dir_exists_absolute(path + $ObjList.get_item_text($ObjList.get_selected_items()[0])):
			STOP = true
			$Selection.size = $ObjList.fixed_icon_size
			$Selection.position = get_global_mouse_position()
			$Selection.color = Color(1.0,1.0,1.0,0.392)
			$Selection.modulate = Color(1.0, 1.0, 1.0, 1.0)
			get_tree().create_tween().set_ease(Tween.EASE_OUT).tween_property($Selection, "size", $ObjList.size, 0.4).set_trans(Tween.TRANS_SINE)
			get_tree().create_tween().set_ease(Tween.EASE_OUT).tween_property($Selection, "position", $ObjList.position, 0.4).set_trans(Tween.TRANS_SINE)
			await get_tree().create_timer(0.2).timeout
			get_tree().create_tween().tween_property($Selection, "color", Color(1.0,1.0,1.0,1.0), 0.2)
			await get_tree().create_timer(0.2).timeout
			get_tree().create_tween().set_ease(Tween.EASE_OUT).tween_property($Selection, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)
			path += temp + "/"
			fetchfolder(path)
			STOP = false
		else:
			print("test")
			
			STOP = true
			prevselection = $ObjList.get_selected_items()
			$ObjList.deselect_all()
			showeditor(path + temp)
	
	
	
func fetchfolder(dir):
	if DirAccess.dir_exists_absolute(dir):
		$ObjList.clear()
		for folder in DirAccess.get_directories_at(dir):
			$ObjList.add_item(folder, load("res://icons/folder.svg"))
		for file in DirAccess.get_files_at(dir):
			if file.ends_with(".txt") or file.ends_with(".cfg"):
				$ObjList.add_item(file, load("res://icons/file.svg"))
			elif file.ends_with(".png") or file.ends_with(".jpg"):
				$ObjList.add_item(file, load("res://icons/picture.svg"))
			else: $ObjList.add_item(file, load("res://icons/unknown.svg"))
		splittenpath = path.split("/", false)
		$Path.text = path
	else:
		showpopup("Error: No such directory!")

func showpopup(text):
	if text != null:
		$Path/Popup/Label.text = text
	get_tree().create_tween().set_ease(Tween.EASE_OUT).tween_property($Path/Popup, "position:y", 32.0, 0.5).set_trans(Tween.TRANS_BACK)

func showeditor(filepath):
	STOP = false
	if $Editors.position.x < -831.0:
		STOP2 = true
		print("test 2")
		get_tree().create_tween().set_ease(Tween.EASE_OUT).tween_property($Editors, "position:x", 0.0, 0.9).set_trans(Tween.TRANS_BOUNCE)
		get_tree().create_tween().set_ease(Tween.EASE_OUT).tween_property($ObjList, "position:x", 1152.0, 0.9).set_trans(Tween.TRANS_BOUNCE)
		await get_tree().create_timer(0.9).timeout
		STOP2 = false
		if filepath != null:
			print(filepath)
			print(str(splittenpath))
			$"Editors/Text Editor/Input".text = FileAccess.get_file_as_string("/" + filepath)
			$"Editors/Code Editor/Input".text = FileAccess.get_file_as_string("/" + filepath)
			print(FileAccess.get_open_error())
			if FileAccess.get_file_as_string("/" + filepath).begins_with("�"):
				$Editors.set_tab_disabled(2, false)
				$Editors.current_tab = 2
				var img1 = Image.load_from_file("/" + filepath)
				var img2 = ImageTexture.create_from_image(img1)
				$"Editors/Image Viewer/TextureRect".texture = img2
			else:
				$Editors.set_tab_disabled(2, true)
				$Editors.current_tab = 0
		else:
			$Editors.set_tab_disabled(2, true)
			$Editors.current_tab = 0
	elif $Editors.position.x > -1.0:
		STOP2 = true
		get_tree().create_tween().set_ease(Tween.EASE_OUT).tween_property($Editors, "position:x", -$Editors.size.x, 0.9).set_trans(Tween.TRANS_BOUNCE)
		get_tree().create_tween().set_ease(Tween.EASE_OUT).tween_property($ObjList, "position:x", 0.0, 0.9).set_trans(Tween.TRANS_BOUNCE)
		await get_tree().create_timer(0.9)
		STOP2 = false
	

func get_popupthingy(id):
	match id:
		0:
			$"Editors/Text Editor/Input".text = ""
			$"Editors/Code Editor/Input".text = ""
		1:
			var openfile = FileAccess.open(path + $ObjList.get_item_text(prevselection[0]), FileAccess.WRITE)
			openfile.store_string($"Editors/Text Editor/Input".text)
			openfile.close()
		2:
			$FileDialog.show()
			await $FileDialog.close_requested
			if $FileDialog.file_selected:
				var openfile = FileAccess.open($FileDialog.current_file, FileAccess.WRITE)
				openfile.store_string($"Editors/Text Editor/Input".text)
				openfile.close()




# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.get_name() == "Android":
		path = "storage/emulated/0/"
		prevpath = path
	$FileDialog.root_subfolder = path
	await OS.request_permissions()
	fetchfolder(path)
	
	$"Editors/Text Editor/MenuBar/File".get_popup().id_pressed.connect(get_popupthingy.bind())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Actions/Label4.text = str(STOP)
	$"Editors/Text Editor/Input".add_theme_font_size_override("font_size", $"Editors/Text Editor/HSlider".value)
	$Selection/TextureRect.size = $Selection.size
	if path == "//":
		path = "/"
		$Path.text = "/"
	
	
	
	
