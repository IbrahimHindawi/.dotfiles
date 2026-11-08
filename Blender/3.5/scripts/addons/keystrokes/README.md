Q:
    S - duplicate, bpy.ops.mesh.duplicate_move()
    D - separate, ?
E:
    A - inset, ?
    E - extrude, bpy.ops.mesh.select_mode(use_extend=False, use_expand=False, type='FACE')
    F - extrude along normals, 
V:
    S - mirror, bpy.ops.object.modifier_add(type='MIRROR')
    D - subdiv, bpy.ops.object.modifier_add(type='SUBSURF')
    X - bisect, bpy.ops.object.bisect_plane()
T:
    R - edge loop, bpy.ops.mesh.loopcut_slide()
    F - knife, bpy.ops.mesh.knife_tool(use_occlude_geometry=True, only_selected=False)

QET
AD
CV

QwE T
A D  
zxCVb
