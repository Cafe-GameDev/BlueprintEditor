@tool
extends EditorPlugin

const AUTOLOAD_NAME = "BlueprintEditor"
const AUTOLOAD_PATH = "res://addons/blueprint_editor/utils/blueprint_editor.gd"
const BLUEPRINT_TOP_PANEL_SCENE_PATH = "res://addons/blueprint_editor/panel/blueprint_top_panel.tscn"
var blueprint_top_panel_instance: Control

func _enable_plugin() -> void:
	if not ProjectSettings.has_setting("autoload/" + AUTOLOAD_NAME):
		add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)

func _disable_plugin() -> void:
	if ProjectSettings.has_setting("autoload/" + AUTOLOAD_NAME):
		remove_autoload_singleton(AUTOLOAD_NAME)

func _enter_tree():
	var scene = load(BLUEPRINT_TOP_PANEL_SCENE_PATH)
	if scene and scene is PackedScene:
		blueprint_top_panel_instance = scene.instantiate()
		EditorInterface.get_editor_main_screen().add_child(blueprint_top_panel_instance)
		blueprint_top_panel_instance.hide()
	else:
		push_error("Could not load BlueprintTopPanel scene from: " + BLUEPRINT_TOP_PANEL_SCENE_PATH)

func _exit_tree():
	if is_instance_valid(blueprint_top_panel_instance):
		blueprint_top_panel_instance.queue_free()

func _create_top_panel():
	pass

func _has_main_screen():
	return true

func _make_visible(visible):
	if is_instance_valid(blueprint_top_panel_instance):
		blueprint_top_panel_instance.visible = visible

func _get_plugin_name():
	return "Blueprints"
