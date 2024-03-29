import bpy

def main(context, delta):
    objects = bpy.context.selected_objects
    print(objects)
    modifiercollections = []
    for object in objects:
        modifiercollections.append(object.modifiers)
    # print(modifiercollections)
    for modifiercollection in modifiercollections:
        # print(modifiercollection)
        for modifier in modifiercollection:
            if modifier.name == 'Subdivision':
                # print(modifier)
                modifier.levels += delta

class SubdivControl(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "object.subdiv_control"
    bl_label = "SubdivControl"
    
    delta: bpy.props.IntProperty(name='Delta')

    @classmethod
    def poll(cls, context):
        return context.active_object is not None

    def execute(self, context):
        main(context, self.delta)
        return {'FINISHED'}


def menu_func(self, context):
    self.layout.operator(SubdivControl.bl_idname, text=SubdivControl.bl_label)


# Register and add to the "object" menu (required to also use F3 search "Simple Object Operator" for quick access).
def register():
    bpy.utils.register_class(SubdivControl)
    bpy.types.VIEW3D_MT_object.append(menu_func)


def unregister():
    bpy.utils.unregister_class(SubdivControl)
    bpy.types.VIEW3D_MT_object.remove(menu_func)


if __name__ == "__main__":
    register()

    # test call
    bpy.ops.object.subdiv_control()
