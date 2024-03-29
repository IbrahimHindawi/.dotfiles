import bpy

def main(context):
    meshprops = bpy.data.window_managers["WinMan"].mesh_check_props

    if meshprops.show_overlay == True:
        meshprops.show_overlay = False
    else:
        meshprops.show_overlay = True


class ToggleBorder(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "object.toggle_border"
    bl_label = "Toggle Border Operator"

    @classmethod
    def poll(cls, context):
        return context.active_object is not None

    def execute(self, context):
        main(context)
        return {'FINISHED'}


def menu_func(self, context):
    self.layout.operator(ToggleBorder.bl_idname, text=ToggleBorder.bl_label)


# Register and add to the "object" menu (required to also use F3 search "Simple Object Operator" for quick access).
def register():
    bpy.utils.register_class(ToggleBorder)
    bpy.types.VIEW3D_MT_object.append(menu_func)


def unregister():
    bpy.utils.unregister_class(ToggleBorder)
    bpy.types.VIEW3D_MT_object.remove(menu_func)


if __name__ == "__main__":
    register()

    # test call
    # bpy.ops.object.toggle_border()
