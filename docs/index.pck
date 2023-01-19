GDPC                  @                                                                         P   res://.godot/exported/133200997/export-3dbd885b59adb8a89e7bac889f9018e0-Main.scn�      �      �	?p�Bu�S��6    P   res://.godot/exported/133200997/export-cd7f7133314728d138b73bb7275c35a9-Card.scn        n      Xai�m�K�B�!f�:    T   res://.godot/exported/133200997/export-dbce8786a59a6dcd284b30a36737d8e9-Lobby.scn    
      �      kqL�o�A�y�d�    L   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.s3tc.ctex   p!      �U      \��Nc=��ʡ�U        res://.godot/uid_cache.bin  ��      �       �޿�ʗ�Q%���Л�I       res://icon.svg  �|      N      ]��s�9^w/�����       res://icon.svg.import    w            Eޟ!c�\�laj1��       res://main/Main.tscn.remap   |      a       ςT��U=|��9�pjW    $   res://main/game/card/Card.tscn.remap@{      a       ���٩h?�sS�wx��    $   res://main/ui/lobby/Lobby.tscn.remap�{      b       ~��]n�����V��D�E    (   res://main/ui/lobby/character_menu.gd   p      �      �W��H@����K       res://main/ui/lobby/lobby.gd       �      ��`P�!��� �i<        res://main/ui/lobby/main_menu.gd�             g _2����	Tk�o�n       res://main/ui/submenu.gd�      �       �����au�R�[���       res://project.binary��      �      �y�#6���4�`#Y��    �1uhS;/��zRSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script    
   Texture2D    res://icon.svg =�?TZ      local://PackedScene_ww0sa 	         PackedScene          	         names "         Card    texture 	   Sprite3D    	   variants                       node_count             nodes     	   ��������       ����                    conn_count              conns               node_paths              editable_instances              version             RSRC˨class_name CharacterMenu
extends Submenu

@export var go_button: Button
@export var left_button: Button
@export var right_button: Button
@export var player_icon: TextureRect
@export var username: LineEdit

signal go_selected

func _ready() -> void:
	go_button.pressed.connect(emit_signal.bind("go_selected"))

func exit() -> void:
	super.exit()
	toggle_input(false)
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.025)

func enter() -> void:
	super.enter()
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.025)
	
	await tween.finished
	toggle_input(true)

func toggle_input(input_enabled: bool) -> void:
	super.toggle_input(input_enabled)
	
	go_button.disabled = not input_enabled
	left_button.disabled = not input_enabled
	right_button.disabled = not input_enabled
	username.editable = input_enabled
D�u���tw@2��class_name Lobby
extends Control

@export var character_menu: CharacterMenu
@export var main_menu: MainMenu

var rooms: Dictionary 

func _ready() -> void:
	character_menu.go_selected.connect(_on_go_selected)
	main_menu.profile_selected.connect(_on_profile_selected)

func _on_go_selected() -> void:
	await character_menu.exit()
	main_menu.enter()

func _on_profile_selected() -> void:
	await main_menu.exit()
	character_menu.enter()

func _enter_tree() -> void:
	pass

func _on_join_selected() -> void:
	pass

func _on_create_selected() -> void:
	pass

func _on_connected(id: int) -> void:
	pass

func _on_disconnected(id: int) -> void:
	pass

func start_network(is_server: bool) -> void:
	var peer = ENetMultiplayerPeer.new()
	if is_server:
		multiplayer.peer_connected.connect(_on_connected)
		multiplayer.peer_disconnected.connect(_on_disconnected)
		peer.create_server(2004)
		
		print("server listening on localhost 2004")
	else:
		peer.create_client("localhost", 2004)
	
	multiplayer.set_multiplayer_peer(peer)
:ɟ�RSRC                     PackedScene            ��������                                                  CharacterMenu 	   MainMenu    Button    HBoxContainer    VBoxContainer    Left    Right    Icon 	   Username    Label    JoinButton    CreateButton    ProfileButton    resource_local_to_scene    resource_name 	   _bundled    script       Script    res://main/ui/lobby/lobby.gd ��������   Script &   res://main/ui/lobby/character_menu.gd ��������
   Texture2D    res://icon.svg =�?TZ   Script !   res://main/ui/lobby/main_menu.gd ��������      local://PackedScene_kpqxr e         PackedScene          	         names "   4      Lobby    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script    character_menu 
   main_menu    Control    CharacterMenu    anchor_left    anchor_top    offset_left    offset_top    offset_right    offset_bottom $   theme_override_constants/separation 
   go_button    left_button    right_button    player_icon 	   username    VBoxContainer    HBoxContainer    Icon    texture    stretch_mode    TextureRect    Left    size_flags_horizontal $   theme_override_font_sizes/font_size    text    Button    Right 	   Username    custom_minimum_size    size_flags_vertical    placeholder_text 	   LineEdit 	   MainMenu    mouse_filter    title    join_button    create_button    profile_button    Label    horizontal_alignment    JoinButton    CreateButton    ProfileButton    	   variants    +                    �?                                               ?    �I�    ��    �IC    �C                                                                                                       <       > 
         �B            Name...       Go      ��     ��     �B     �B               	         
                     
         �C   Z         Rook!             Join a game       Create a game       Change user       node_count             nodes     �   ��������
       ����	                                                @   	  @                     ����                                    	      
                                         @     @     @     @     @                    ����                          ����                          ����                                ����               "      ����                 !                 "   #   ����                 !                 (   $   ����   %             &             '                 "   "   ����   %             !                     )   ����                                                                     *            +  @    ,  @!   -  @"   .  @#       
       /   /   ����   %   $       %   !   &   0   '       
       "   1   ����          !   (       
       "   2   ����          !   )       
       "   3   ����          !   *             conn_count              conns               node_paths              editable_instances              version             RSRCclass_name MainMenu
extends Submenu

@export var title: Control
@export var join_button: Button
@export var create_button: Button
@export var profile_button: Button

signal profile_selected

func _ready() -> void:
	join_button.modulate.a = 0
	create_button.modulate.a = 0
	profile_button.modulate.a = 0
	
	profile_button.pressed.connect(emit_signal.bind("profile_selected"))
	
	toggle_input(false)

func enter() -> void:
	super.enter()
	
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(title, "custom_minimum_size:y", 0.0, 0.2)
	
	await tween.finished
	
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(join_button, "modulate:a", 1.0, 0.025)
	tween.tween_property(create_button, "modulate:a", 1.0, 0.025)
	tween.tween_property(profile_button, "modulate:a", 1.0, 0.025)
	
	await tween.finished
	toggle_input(true)

func exit() -> void:
	super.exit()
	toggle_input(false)
	
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	
	tween.tween_property(join_button, "modulate:a", 0.0, 0.025)
	tween.tween_property(create_button, "modulate:a", 0.0, 0.025)
	tween.tween_property(profile_button, "modulate:a", 0.0, 0.025)
	tween.tween_property(title, "custom_minimum_size:y", 400.0, 0.2)
	
	await tween.finished

func toggle_input(input_enabled: bool) -> void:
	super.toggle_input(input_enabled)
	join_button.disabled = not input_enabled
	create_button.disabled = not input_enabled
	profile_button.disabled = not input_enabled
class_name Submenu
extends Control

signal exited
signal entered

func enter() -> void:
	entered.emit()

func exit() -> void:
	exited.emit()

func toggle_input(input_enabled: bool) -> void:
	pass
���d�D���{YRSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       PackedScene    res://main/ui/lobby/Lobby.tscn ���-�$G   PackedScene    res://main/game/card/Card.tscn �M<���[1      local://PackedScene_amwko V         PackedScene          	         names "   
      Main    Node    Lobby    Game    visible    Node3D    Card 	   Camera3D 
   transform    current    	   variants                                      �?            5�c?���>    ���5�c?    !��?���?            node_count             nodes     )   ��������       ����                ���                             ����                    ���                           ����         	                conn_count              conns               node_paths              editable_instances              version             RSRC�U��6��k�(GST2   �   �     �����                � �               h)g!W_|�� I�$I�g!&!0�P� I�   g)&!\UU���     F!&!\UUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU�         &!UUUU��X    F!&!5UUU� N�   �)&!:5UU� I�$K=�)&!0        �)g)����� I��I�h)&! _~�D     �)&!VUU�       �1&!U% �       �1�))   �         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       �1h)x   �       �1&!UX� �A     �)&!UUT� I�$J&�)&! ��=� 9�P g)&!P_UT�       �1&!5	�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       �1&!\P`@� �, ��)&!�U���P   F!&!TWWU�       �1h) �         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       �1h)@�� �� �  F!&!�UU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       �:�1UUU�       WD2UU- �       WD2�  �       WD:B�  �       �:�1UUUT�         �1UUUU�         �1UUUU�       ;�1UUU�       WD:�  �       WD2W�  �       WD2UUx �       �:�1UUUT�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       WD2�         wDUUUU�         wDUUUU�         wDUUUU�       WD2T\Pp�         �1UUUU�         �1UUUU�       WD25�         wDUUUU�         wDUUUU�         wDUUUU�       WD2PPPP�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       WD2%%5�         wDUUUU�         wDUUUU�         wDUUUU�       WDL:@   �       WD�:�   �       WD�:W   �       WDl:   �         wDUUUU�         wDUUUU�         wDUUUU�       WD2XXX\�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       WD2555�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�       WD2\\\@�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       7D2UU�5�       WD:y  �       WD2UWP��       �:�1UUU�       WD2� �       wLWD�����         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�       wDWD@   �       WD2WP� �       �:�1UUUT�       WD2U��       WD:m�  �       7D2UUW\�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       �:�1UUU�       WD2 �         wDUUUU�         wDUUUU�       WD�:4   �         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�       WD�:   �         wDUUUU�         wDUUUU�       WD2P@� �       �:�1UUUT�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       WD2%�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�       WD2TXpp�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       WD2�U�       WD�C   �         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�       WD�C   @�       WD2PTWU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       WD2%�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�       WD2@pXT�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       WD2�         wDUUUU�         wDUUUU�       \��LUUU�       ���T� �       �����  `�       ���T^�  �       ���TUUVX�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�       ���TUU�%�       ���T�  �       ����{  	�       ���TWp� �       \��LUUUT�         wDUUUU�         wDUUUU�       WD2TTTT�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       WD2�         wDUUUU�         wDUUUU�       ���T5�       ��IJ @pP�       �)BTUUU�       ��IJ%�UU�       ���R���         wDUUUU�         wDUUUU�       ���TU��       ���TUWp@�         wDUUUU�         wDUUUU�       ���R�B�       ��IJXWUU�       4�)BUUU�       ��IJ �       ���T\PPp�         wDUUUU�         wDUUUU�       WD2TTTT�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       WD2�         wDUUUU�         wDUUUU�       ���T			�       ��IJX\\X�         BUUUU�         BUUUU�       ��IJ�����         wDUUUU�         wDUUUU�       ���T�       ���T@@@@�         wDUUUU�         wDUUUU�       ��IJB`bB�         BUUUU�         BUUUU�       ��IJ%55%�       ���T```p�         wDUUUU�         wDUUUU�       WD2TTTT�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       WD2�         wDUUUU�         wDUUUU�       ���T%U�       ��IJP`� �       ��IJUUUx�       ��IJUU�       ���SA`p\�         wDUUUU�         wDUUUU�       ���T�       ���T@@@@�         wDUUUU�         wDUUUU�       ���SC	5�       ��IJUUT��       ��IJUUU-�       ��IJ	 �       ���TPXTU�         wDUUUU�         wDUUUU�       WD2TTTT�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       WD2�         wDUUUU�         wDUUUU�         wDUUUU�       ���T5UU�       ���T  �U�       ���T pUU�       �dwLTUUU�         wDUUUU�         wDUUUU�       ���T	U�       ���T@`PU�         wDUUUU�         wDUUUU�       �dwLUUU�       ���T UU�       ���T  U�       ���T@\UU�         wDUUUU�         wDUUUU�         wDUUUU�       WD2TTTT�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       WD2�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�       WD2TTTT�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       ��KB��       ���t�  ��       ��YuW  �       ���TU   �       ���TUz� �         wDUUUU�         wDUUUU�         wDUUUU�       טTUUU�       ��TUUU �       ��TUUU �       ��TUUU �       ��TUUU �       ϘTUUUT�         wDUUUU�         wDUUUU�         wDUUUU�       ���TU� �       ���TU   �       ��Yu�  ��       ���t
  ^�       ��KBTTTW�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       WD2�         wDUUUU�       �TwDUUU�       ��xLUUU�       ��Yu�       �TwDUUUT�         wDUUUU�         wDUUUU�       ���T%�       ���T  �T�       ���T  �U�       ���T  �U�       ���T  /�       ���TXPPP�         wDUUUU�         wDUUUU�       �TwDUUU�       ��9u�@@@�       ��xL�UUU�       �TwDTUUU�         wDUUUU�       WD2TTTT�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       D2���         wDUUUU�         wDUUUU�         wDUUUU�       ���T�       ���TUW  �       ���TUU  �       ���TUU� �       ���T �       ���TTTTV�         wDUUUU�         wDUUUU�       ���T��       ���TPp� �       ���TUU� �       ���TUU  �       ���TU�  �       ���T@@@@�         wDUUUU�         wDUUUU�         wDUUUU�       �C
2TTVW�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       WD2 �         wDUUUU�         wDUUUU�       ~�TUUU�       ���T UUU�       ���T �UU�       ���T �UU�       ���T �UU�       ��xLTUUU�         wDUUUU�         wDUUUU�       ��xLUUU�       ���T UU�       ���T �UU�       ���T UU�       ���T UUU�       ~�TpUUU�         wDUUUU�         wDUUUU�       WD2 �@P�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       WD25�UU�       WD2  �         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�       WD2  �p�       WD2\VUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       �C
2UUU�       WD2 5U�       WD�:   	�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�       WD�:   `�       WD2 �\U�       �C
2TUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       ;�1UUU�       WD2 �UU�       WD2  �U�       WD2   U�       WD�:   ��       WD�C   ��       wL6D   �       wL6D   p�       WD�C   _�       WD�:   ^�       WD2   U�       WD2  ^U�       WD2 ^UU�       ;�1TUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�         &!UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       
2�15UUU�       
2�1\UUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         &!UUUU�� 0  F!&!UUWT�       �1h) �         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       �1h) ��@��  ` 
 F!&!U��  �g!&!VV_P�       �1&!	5�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       �1&!@`P\�   �$�)&!��U� 	�DI�$g!&!`h �:     �)&!UUT�       �1&! %U�       �1g)   -�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       �1g)   x�       �1&! @XU�9      �)&!TUU� `�$I�$�)&!=�         �)g!����� ���I�$�)&!Z��>�    ��h)&!UU\���    �RF!&!UUU���    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��    �$  &!UUUU��     6F!&!UUU-�    ��$�!&!UU54� P�$I�$�)&!>        �)g)����� I�d��g)&!�`p��7�     �1&!UU �       �1&!UU  �       �1&!UU  �       �1&!UU  �       �1&!UU  �       �1&!UU  �       �1&!UU  �       �1&!UU  �       �1&!UU  �       �1&!UU  �       �1&!UU  �       �1&!UU  �       �1&!UU  �6P    �1&!�Up � I�$P,�)&! ��7P   �1&!5�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�5 �  �1&!�\PP�       �1&!�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       D2UUU%�       WD2UU� �       +:�1UUUT�       ,:�1UUU�       WD2UU� �       D2UUUX�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       �1&!PPPP�       �1&!�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       WD2�         wDUUUU�       WD2VT� �       WD2�
 �         wDUUUU�       WD2@@@@�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�       �1&!PPPP�       �1&!�         �1UUUU�       �:�1UUU�       WD2UUZ��       WD2UU��       WD2	  �         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�       WD2`@  �       WD2UUVP�       WD2UU��       �:�1UUUT�         �1UUUU�       �1&!PPPP�       �1&!�         �1UUUU�       WD25	�         wDUUUU�       wD�C   �         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�       wD�Cp   �         wDUUUU�       WD2\P`@�         �1UUUU�       �1&!PPPP�       �1&!�         �1UUUU�       WD2	5��         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�       WD2`P\V�         �1UUUU�       �1&!PPPP�       �1&!�         �1UUUU�       1C�1�         wDUUUU�       ���R�C�       ��IJ� �U�       ���TUV\Z�       ���TUUU5�       ���TUUU\�       ���TU�5��       ��IJ VU�       ���R�����         wDUUUU�       0;�1TTTT�         �1UUUU�       �1&!PPPP�       �1&!�         �1UUUU�       1C�1�         wDUUUU�       ��IJbBC�       �IJUUU7�       �qTQQXT�       ���T5555�       ���T\\\\�       �qTEE%�       �IJUUU��       ��IJ�����         wDUUUU�       0;�1TTTT�         �1UUUU�       �1&!PPPP�       �1&!�         �1UUUU�       1C�1�         wDUUUU�       >ߘT5UUU�       ���T�UUU�       �LwDTUUU�       ���T5�UU�       ���T\WUU�       �LwDUUU�       ���TUUU�       >ߘT\UUU�         wDUUUU�       0;�1TTTT�         �1UUUU�       �1&!PPPP�       �1&!�         �1UUUU�       ��
:����       ���T�UU�       ���T~ %�       xLwDUUUT�       ���TUU�       ���TU� V�       ���TU� ��       ���TUUTT�       xLwDUUU�       ���T� PX�       ���T
�UU�       Ԕ
:TVWW�         �1UUUU�       �1&!PPPP�       �1&!�         �1UUUU�       �:�1�UU�       WD�:  �       ���T%5�U�       ���TU �U�       ���T  U�       �xLTVUU�       �xL��U�       ���TT  U�       ���TU �U�       ���TX\WU�       WD�:  �@�       �:�1TWUU�         �1UUUU�       �1&!PPPP�       �1&!�         �1UUUU�         �1UUUU�       WD25UU�       WD:   �         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�         wDUUUU�       WD2   x�       WD2p\UU�         �1UUUU�         �1UUUU�       �1&!PPPP�       �1&!�         �1UUUU�         �1UUUU�         �1UUUU�       L:�1UUU�       WD2UUU�       WD2 +UU�       WD2  UU�       WD2  UU�       WD2 �UU�       WD2�UUU�       L:�1TUUU�         �1UUUU�         �1UUUU�         �1UUUU�       �1&!PPPP�4    �1&!5�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�         �1UUUU�2  @ 
 �1&!PP\�� !�I�$�)&!VZB��1    �
�1&! -UW���$I��$�1&!  UU���$I��$�1&!  UU���$I��$�1&!  UU���$I��$�1&!  UU���$I��$�1&!  UU���$I��$�1&!  UU���$I��$�1&!  UU���$I��$�1&!  UU���$I��$�1&!  UU���$I��$�1&!  UU���$I��$�1&!  UU���$I��$�1&!  UU�0     5�1&! xU��  %L�$�)&!��� �p   �1&!W%	�       �1&!U   �       �1&!U   �       �1&!U   �       �1&!U   �       �1&!U   �       �1&!U   � ��  �1&!��`@�       �1&!�         �1UUUU�       WD2U�55�       WD2URp �       WD2U� �       WD2UW\\�         �1UUUU�       �1&!@@@@�       �1&!�       WD2U��       WD25	  �         wDUUUU�         wDUUUU�       WD2\`  �       WD2US@��       �1&!@@@@�       �1&!�       WD2	�       ]�R��Z�       {��LUUU��       {��LUUU�       ]�R�����       WD2@ppp�       �1&!@@@@�       �1&!�       WD2�       {�IJ\���       �ΘL�U�       �ƘL��VU�       {�IJ5����       WD2pppp�       �1&!@@@@�       �1&!�       �+B����       >טTXQ���       �ƘL�	rZ�       �ƘL_`���       >טT%EJ_�       �+BP___�       �1&!@@@@�       �1&!�       �C
2UUU�       WD2 �U�       WD2  U�       WD2  �U�       WD2 �^U�       �C
2TUUU�       �1&!@@@@�  0 ��1&!	%_��$I�$�$�1&!   U��$I�$�$�1&!   U��$I�$�$�1&!   U��$I�$�$�1&!   U��$I�$�$�1&!   U��$I�$�$�1&!   U�   ` �=�1&!@`���R     �1G!��       7D�)UUu��       7D�)UU]B�R�@   �1g!_@���       7D�)�%%5�       ���:�����       ���:z��
�       7D�)WXX\�       ���1����       ;��J$�,��       ;��J�8��       ���1VVTV�Q   �:g!)��U�       7D�) �UU�       7D�) ~UU�Q    (�:g)hjjU��     �l�1U�-	��     �l�1U_x`��     9}�1	�U��      9}�1p`^U��   �t�1UA�U�       C�:U   �         �BUUUU/{�N�����TL0[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://cyqcg4k2g68ht"
path.s3tc="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.s3tc.ctex"
path.etc2="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.etc2.ctex"
metadata={
"imported_formats": ["s3tc", "etc2"],
"vram_texture": true
}

[deps]

source_file="res://icon.svg"
dest_files=["res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.s3tc.ctex", "res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.etc2.ctex"]

[params]

compress/mode=2
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/bptc_ldr=0
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=true
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=0
svg/scale=1.0
editor/scale_with_editor_scale=false
editor/convert_colors_with_editor_theme=false
tr!��3�[remap]

path="res://.godot/exported/133200997/export-cd7f7133314728d138b73bb7275c35a9-Card.scn"
&�W�~�>��e�[remap]

path="res://.godot/exported/133200997/export-dbce8786a59a6dcd284b30a36737d8e9-Lobby.scn"
�QF��O���Nb[remap]

path="res://.godot/exported/133200997/export-3dbd885b59adb8a89e7bac889f9018e0-Main.scn"
#26���y{��(W,<svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><g transform="translate(32 32)"><path d="m-16-32c-8.86 0-16 7.13-16 15.99v95.98c0 8.86 7.13 15.99 16 15.99h96c8.86 0 16-7.13 16-15.99v-95.98c0-8.85-7.14-15.99-16-15.99z" fill="#363d52"/><path d="m-16-32c-8.86 0-16 7.13-16 15.99v95.98c0 8.86 7.13 15.99 16 15.99h96c8.86 0 16-7.13 16-15.99v-95.98c0-8.85-7.14-15.99-16-15.99zm0 4h96c6.64 0 12 5.35 12 11.99v95.98c0 6.64-5.35 11.99-12 11.99h-96c-6.64 0-12-5.35-12-11.99v-95.98c0-6.64 5.36-11.99 12-11.99z" fill-opacity=".4"/></g><g stroke-width="9.92746" transform="matrix(.10073078 0 0 .10073078 12.425923 2.256365)"><path d="m0 0s-.325 1.994-.515 1.976l-36.182-3.491c-2.879-.278-5.115-2.574-5.317-5.459l-.994-14.247-27.992-1.997-1.904 12.912c-.424 2.872-2.932 5.037-5.835 5.037h-38.188c-2.902 0-5.41-2.165-5.834-5.037l-1.905-12.912-27.992 1.997-.994 14.247c-.202 2.886-2.438 5.182-5.317 5.46l-36.2 3.49c-.187.018-.324-1.978-.511-1.978l-.049-7.83 30.658-4.944 1.004-14.374c.203-2.91 2.551-5.263 5.463-5.472l38.551-2.75c.146-.01.29-.016.434-.016 2.897 0 5.401 2.166 5.825 5.038l1.959 13.286h28.005l1.959-13.286c.423-2.871 2.93-5.037 5.831-5.037.142 0 .284.005.423.015l38.556 2.75c2.911.209 5.26 2.562 5.463 5.472l1.003 14.374 30.645 4.966z" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 919.24059 771.67186)"/><path d="m0 0v-47.514-6.035-5.492c.108-.001.216-.005.323-.015l36.196-3.49c1.896-.183 3.382-1.709 3.514-3.609l1.116-15.978 31.574-2.253 2.175 14.747c.282 1.912 1.922 3.329 3.856 3.329h38.188c1.933 0 3.573-1.417 3.855-3.329l2.175-14.747 31.575 2.253 1.115 15.978c.133 1.9 1.618 3.425 3.514 3.609l36.182 3.49c.107.01.214.014.322.015v4.711l.015.005v54.325c5.09692 6.4164715 9.92323 13.494208 13.621 19.449-5.651 9.62-12.575 18.217-19.976 26.182-6.864-3.455-13.531-7.369-19.828-11.534-3.151 3.132-6.7 5.694-10.186 8.372-3.425 2.751-7.285 4.768-10.946 7.118 1.09 8.117 1.629 16.108 1.846 24.448-9.446 4.754-19.519 7.906-29.708 10.17-4.068-6.837-7.788-14.241-11.028-21.479-3.842.642-7.702.88-11.567.926v.006c-.027 0-.052-.006-.075-.006-.024 0-.049.006-.073.006v-.006c-3.872-.046-7.729-.284-11.572-.926-3.238 7.238-6.956 14.642-11.03 21.479-10.184-2.264-20.258-5.416-29.703-10.17.216-8.34.755-16.331 1.848-24.448-3.668-2.35-7.523-4.367-10.949-7.118-3.481-2.678-7.036-5.24-10.188-8.372-6.297 4.165-12.962 8.079-19.828 11.534-7.401-7.965-14.321-16.562-19.974-26.182 4.4426579-6.973692 9.2079702-13.9828876 13.621-19.449z" fill="#478cbf" transform="matrix(4.162611 0 0 -4.162611 104.69892 525.90697)"/><path d="m0 0-1.121-16.063c-.135-1.936-1.675-3.477-3.611-3.616l-38.555-2.751c-.094-.007-.188-.01-.281-.01-1.916 0-3.569 1.406-3.852 3.33l-2.211 14.994h-31.459l-2.211-14.994c-.297-2.018-2.101-3.469-4.133-3.32l-38.555 2.751c-1.936.139-3.476 1.68-3.611 3.616l-1.121 16.063-32.547 3.138c.015-3.498.06-7.33.06-8.093 0-34.374 43.605-50.896 97.781-51.086h.066.067c54.176.19 97.766 16.712 97.766 51.086 0 .777.047 4.593.063 8.093z" fill="#478cbf" transform="matrix(4.162611 0 0 -4.162611 784.07144 817.24284)"/><path d="m0 0c0-12.052-9.765-21.815-21.813-21.815-12.042 0-21.81 9.763-21.81 21.815 0 12.044 9.768 21.802 21.81 21.802 12.048 0 21.813-9.758 21.813-21.802" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 389.21484 625.67104)"/><path d="m0 0c0-7.994-6.479-14.473-14.479-14.473-7.996 0-14.479 6.479-14.479 14.473s6.483 14.479 14.479 14.479c8 0 14.479-6.485 14.479-14.479" fill="#414042" transform="matrix(4.162611 0 0 -4.162611 367.36686 631.05679)"/><path d="m0 0c-3.878 0-7.021 2.858-7.021 6.381v20.081c0 3.52 3.143 6.381 7.021 6.381s7.028-2.861 7.028-6.381v-20.081c0-3.523-3.15-6.381-7.028-6.381" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 511.99336 724.73954)"/><path d="m0 0c0-12.052 9.765-21.815 21.815-21.815 12.041 0 21.808 9.763 21.808 21.815 0 12.044-9.767 21.802-21.808 21.802-12.05 0-21.815-9.758-21.815-21.802" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 634.78706 625.67104)"/><path d="m0 0c0-7.994 6.477-14.473 14.471-14.473 8.002 0 14.479 6.479 14.479 14.473s-6.477 14.479-14.479 14.479c-7.994 0-14.471-6.485-14.471-14.479" fill="#414042" transform="matrix(4.162611 0 0 -4.162611 656.64056 631.05679)"/></g></svg>
   �M<���[1   res://main/game/card/Card.tscn���-�$G   res://main/ui/lobby/Lobby.tscn=�?TZ   res://icon.svgk���g�F
   res://main/Main.tscn�
@�d�4�6'��ECFG	      _global_script_classesl                    class         CharacterMenu         language      GDScript      path   %   res://main/ui/lobby/character_menu.gd         base      Submenu             class         Lobby         language      GDScript      path      res://main/ui/lobby/lobby.gd      base      Control             class         MainMenu      language      GDScript      path       res://main/ui/lobby/main_menu.gd      base      Submenu             class         Submenu       language      GDScript      path      res://main/ui/submenu.gd      base      Control    _global_script_class_iconsp               CharacterMenu                Lobby                MainMenu             Submenu           application/config/name         rook-online    application/run/main_scene         res://main/Main.tscn   application/config/features(   "         4.0    GL Compatibility       application/config/icon         res://icon.svg     display/window/stretch/mode         canvas_items   display/window/stretch/aspect         expand  #   rendering/renderer/rendering_method         gl_compatibility��0�HB��K