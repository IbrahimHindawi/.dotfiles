bl_info = {
    "name": "Key Strokes — JSON Popup + Hot Reload",
    "author": "Stack & Byte",
    "version": (1, 5, 0),
    "blender": (4, 0, 0),
    "location": "JSON-driven",
    "description": "Press family key → popup menu → click item. Ctrl+Shift+R to reload keystrokes.json.",
    "category": "3D View",
}

import bpy
import json
import os
from typing import Any, Dict, List, Tuple, Optional

# -------------------- Globals --------------------
_JSON_NAME = "keystrokes.json"

# Families: family -> mode -> list[(label, op_id, args, icon)]
FAMILIES: Dict[str, Dict[str, List[Tuple[str, str, dict, str]]]] = {}
# Binds: [(keymap_name, key, modifiers_dict, family)]
BINDINGS: List[Tuple[str, str, dict, str]] = []

_keymaps_bound: List[Tuple[bpy.types.KeyMap, bpy.types.KeyMapItem]] = []
_reload_hotkey: Optional[Tuple[bpy.types.KeyMap, bpy.types.KeyMapItem]] = None


# -------------------- Utils --------------------
def _mode_key(ctx) -> str:
    if ctx.mode.startswith("EDIT_MESH"): return "EDIT_MESH"
    if ctx.mode == "OBJECT": return "OBJECT"
    return ctx.mode or "OBJECT"


def _json_path() -> str:
    return os.path.join(os.path.dirname(__file__), _JSON_NAME)


def _read_config_source() -> str:
    """Strictly read the sidecar keystrokes.json (ignore Blender Text blocks)."""
    path = _json_path()
    if not os.path.isfile(path):
        raise FileNotFoundError(f"[keystrokes] Missing {_JSON_NAME} at: {path}")
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


# -------------------- Custom ops used by your JSON --------------------
class MESH_OT_faces_extrude(bpy.types.Operator):
    """Switch to Face select then Extrude Region (invoke)"""
    bl_idname = "mesh.faces_extrude_invoke"
    bl_label = "Faces → Extrude Region"
    bl_options = {'REGISTER', 'UNDO'}

    @classmethod
    def poll(cls, ctx): return ctx.mode == "EDIT_MESH"

    def execute(self, ctx):
        bpy.ops.mesh.select_mode(use_extend=False, use_expand=False, type='FACE')
        return bpy.ops.mesh.extrude_region_move('INVOKE_DEFAULT')


class OBJECT_OT_add_modifier_safe(bpy.types.Operator):
    """Ensure Object Mode, add modifier to active object, then restore previous mode"""
    bl_idname = "object.add_modifier_safe"
    bl_label = "Add Modifier (Safe)"
    bl_options = {'REGISTER', 'UNDO'}

    type: bpy.props.StringProperty(name="Modifier Type", default="MIRROR")

    def execute(self, ctx):
        obj = ctx.view_layer.objects.active
        if not obj:
            self.report({'WARNING'}, "No active object")
            return {'CANCELLED'}

        prev_mode = ctx.mode
        if prev_mode != "OBJECT":
            try: bpy.ops.object.mode_set(mode='OBJECT')
            except Exception:
                self.report({'WARNING'}, "Cannot switch to Object Mode")
                return {'CANCELLED'}

        try:
            bpy.ops.object.modifier_add(type=self.type)
        except Exception as e:
            self.report({'WARNING'}, f"Could not add modifier {self.type}: {e}")
            if prev_mode != "OBJECT":
                try: bpy.ops.object.mode_set(mode=prev_mode)
                except Exception: pass
            return {'CANCELLED'}

        if prev_mode != "OBJECT":
            try: bpy.ops.object.mode_set(mode=prev_mode)
            except Exception: pass

        return {'FINISHED'}


# -------------------- JSON loader (matches your original layout) --------------------
def load_config_from_json(src: str):
    """Load binds and per-mode family menu items from JSON (popup style)."""
    global FAMILIES, BINDINGS
    FAMILIES = {}
    BINDINGS = []
    data = json.loads(src)

    # binds
    for b in data.get("binds", []):
        keymap = str(b.get("keymap", "Object Mode"))
        key = str(b.get("key", "E")).upper()
        mods = b.get("modifiers", {"shift": False, "ctrl": False, "alt": False})
        family = str(b.get("family", key))
        BINDINGS.append((keymap, key, mods, family))

    # families: per-mode items become popup rows with label+operator+args+icon
    for fam_key, modes in data.get("families", {}).items():
        FAMILIES[fam_key] = {}
        for mode, items in modes.items():
            FAMILIES[fam_key][mode] = []
            for item in items:
                label = f"{item.get('key', '')} — {item.get('label', '')}"
                op_id = item.get("operator", "")
                args = item.get("args", {}) or {}
                icon = item.get("icon", "NONE") or "NONE"
                FAMILIES[fam_key][mode].append((label, op_id, args, icon))


# -------------------- Popup operator (like your original) --------------------
class WM_OT_keystrokes_popup(bpy.types.Operator):
    """Key Strokes popup: draws items from FAMILIES[family][mode]"""
    bl_idname = "wm.keystrokes_popup"
    bl_label = "Key Strokes Popup"

    family: bpy.props.StringProperty(name="Family Key", default="E")

    def invoke(self, context, event):
        fam = FAMILIES.get(self.family, {})
        items = fam.get(_mode_key(context), []) or fam.get("OBJECT", [])
        if not items:
            self.report({'WARNING'}, f"No items for family '{self.family}' in mode '{_mode_key(context)}'")
            return {'CANCELLED'}

        def draw_cb(popup, _ctx):
            layout = popup.layout
            layout.operator_context = 'INVOKE_DEFAULT'
            for label, op_id, kwargs, icon in items:
                try:
                    op = layout.operator(op_id, text=label, icon=icon or 'NONE')
                except Exception:
                    op = layout.operator(op_id, text=label, icon='NONE')
                for k, v in kwargs.items():
                    try: setattr(op, k, v)
                    except Exception: pass

        context.window_manager.popup_menu(draw_cb, title="", icon='NONE')
        return {'FINISHED'}


# -------------------- Bind/unbind --------------------
def _unbind_all():
    global _keymaps_bound
    for km, kmi in _keymaps_bound:
        try: km.keymap_items.remove(kmi)
        except Exception: pass
    _keymaps_bound = []


def _get_or_create_km(kc: bpy.types.KeyConfig, name: str) -> bpy.types.KeyMap:
    km = kc.keymaps.get(name)
    if km is None:
        km = kc.keymaps.new(name=name, space_type='EMPTY')
    return km


def _bind_from_config():
    """Bind each entry to the popup operator (exactly like your original)."""
    _unbind_all()
    kc = bpy.context.window_manager.keyconfigs.addon
    if not kc: 
        print("[keystrokes] No addon keyconfig; skipping bind.")
        return
    for keymap_name, key, mods, family in BINDINGS:
        km = _get_or_create_km(kc, keymap_name)
        try:
            kmi = km.keymap_items.new(
                "wm.keystrokes_popup",
                type=key, value='PRESS',
                shift=mods.get('shift', False),
                ctrl=mods.get('ctrl', False),
                alt=mods.get('alt', False),
            )
            kmi.properties.family = family
            _keymaps_bound.append((km, kmi))
        except Exception as ex:
            print(f"[keystrokes] Failed to bind {keymap_name}:{key} -> {family}: {ex}")


# -------------------- Reload operator --------------------
class WM_OT_keystrokes_reload(bpy.types.Operator):
    """Reload Key Strokes config (sidecar JSON only)"""
    bl_idname = "wm.keystrokes_reload"
    bl_label = "Reload Key Strokes Config"

    def execute(self, context):
        try:
            src = _read_config_source()
            load_config_from_json(src)
            _unbind_all()
            _bind_from_config()
            self.report({'INFO'}, "Key Strokes JSON reloaded")
            return {'FINISHED'}
        except Exception as e:
            self.report({'ERROR'}, f"Reload failed: {e}")
            return {'CANCELLED'}


# -------------------- Registration --------------------
_classes = (
    MESH_OT_faces_extrude,          # used by your JSON
    OBJECT_OT_add_modifier_safe,    # used by your JSON
    WM_OT_keystrokes_popup,         # popup before the second click (restored)
    WM_OT_keystrokes_reload,
)

def _bind_reload_hotkey():
    global _reload_hotkey
    kc = bpy.context.window_manager.keyconfigs.addon
    if not kc: return
    km = _get_or_create_km(kc, "Window")
    try:
        kmi = km.keymap_items.new("wm.keystrokes_reload", type='R', value='PRESS', ctrl=True, shift=True)
        _reload_hotkey = (km, kmi)
    except Exception as ex:
        print(f"[keystrokes] Failed to bind reload hotkey: {ex}")

def _unbind_reload_hotkey():
    global _reload_hotkey
    if _reload_hotkey:
        km, kmi = _reload_hotkey
        try: km.keymap_items.remove(kmi)
        except Exception: pass
        _reload_hotkey = None

def register():
    for c in _classes:
        bpy.utils.register_class(c)
    try:
        src = _read_config_source()
        load_config_from_json(src)
        _bind_from_config()
        print("[keystrokes] Loaded keystrokes.json")
    except Exception as ex:
        print(f"[keystrokes] Initial load failed: {ex}")
    _bind_reload_hotkey()

def unregister():
    _unbind_all()
    _unbind_reload_hotkey()
    for c in reversed(_classes):
        try: bpy.utils.unregister_class(c)
        except Exception: pass

if __name__ == "__main__":
    register()
