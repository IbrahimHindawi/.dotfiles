bl_info = {
    "name": "BisectPlane",
    "author": "Ibrahim El Hindawi",
    "version": (1, 0),
    "blender": (2, 80, 0),
    "location": "3D Viewport > Sidebar > Bisect Plane",
    "description": "Bisects a mesh based on a plane",
    "warning": "",
    "doc_url": "",
    "category": "Mesh",
}


import bpy
from bpy.types import (Panel, Operator)
from bpy.props import FloatVectorProperty
from bpy_extras.object_utils import AddObjectHelper, object_data_add
from mathutils import Vector

def main(context, clear_inner, clear_outer):
    bpy.ops.mesh.bisect(
    plane_co = (0.0, 0.0, 0.0),
    plane_no = (1.0, 0.0, 0.0),
    clear_inner = clear_inner,
    clear_outer = clear_outer
    )

class MESH_OT_BisectPlaneOperator(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "object.bisect_plane"
    bl_label = "Bisect Plane Operator"
    bl_options = {"REGISTER", "UNDO"}
    
    clear_inner: bpy.props.BoolProperty(name='Clear Inner')
    clear_outer: bpy.props.BoolProperty(name='Clear Outer')
    
    @classmethod
    def poll(cls, context):
        return context.active_object is not True
    
    def execute(self, context):
        main(context, self.clear_inner, self.clear_outer)
        return {'FINISHED'}


class VIEW3D_PT_BisectPlanePanel(bpy.types.Panel):
    """Creates a panel in the object properties window"""
    bl_label = "Bisect Plane"
    bl_category = "Bisect Plane"
    bl_space_type = "VIEW_3D"
    bl_region_type = "UI"

    
    #clear_inner: bpy.props.BoolProperty(name='Clear Inner')
    #clear_outer: bpy.props.BoolProperty(name='Clear Outer')
    
    def draw(self,context):
        layout = self.layout
        obj = context.object
        row = layout.row()
        row.operator(MESH_OT_BisectPlaneOperator.bl_idname, text='Bisect', icon='DRIVER_DISTANCE')
        
        
# Registration
def register():
    bpy.utils.register_class(MESH_OT_BisectPlaneOperator)
    bpy.utils.register_class(VIEW3D_PT_BisectPlanePanel)


def unregister():
    bpy.utils.unregister_class(MESH_OT_BisectPlaneOperator)
    bpy.utils.unregister_class(VIEW3D_PT_BisectPlanePanel)


if __name__ == "__main__":
    register()
    # bpy.ops.object.bisect_plane()