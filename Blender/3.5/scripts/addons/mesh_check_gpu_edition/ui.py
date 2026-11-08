# -*- coding:utf-8 -*-

# Blender Mesh Check Add-on
# Copyright (C) 2018 Legigan Jeremy AKA Pistiwique
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# <pep8 compliant>


import bpy

from .mesh_check import MeshCheck as MC


def mesh_check_panel(self, context):
    mesh_check = context.window_manager.mesh_check_props
    addon_prefs = context.preferences.addons[
        __name__.split(".")[0]].preferences
    layout = self.layout
    row = layout.row(align=True)
    row.active = context.object is not None
    check_icon = "PLAY" if mesh_check.check_data else "SNAP_FACE"
    overlay_icon = "OUTLINER_OB_LIGHT" if mesh_check.show_overlay else \
        "LIGHT"
    row.prop(mesh_check, "check_data",
             text="Check Data",
             icon=check_icon)
    row.prop(mesh_check, "show_overlay",
             text="Show Overlay",
             icon=overlay_icon)
    box = layout.box()
    mesh_check.draw_options(box)

    box.prop(addon_prefs, 'edges_offset')
    box.prop(addon_prefs, 'points_offset')

    for obj, mc_object in MC.objects.items():
        ob_box = layout.box()
        row_name = ob_box.row()
        row_name.alignment = 'LEFT'
        icon = 'TRIA_DOWN' if obj.mesh_check_statistics else \
            'TRIA_RIGHT'
        row_name.prop(obj, 'mesh_check_statistics',
                      text=obj.name,
                      icon=icon,
                      emboss=False)
        if obj.mesh_check_statistics:
            checker_options = (("non_manifold", "Non manifold"),
                               ("triangles", "Triangles"),
                               ("ngons", "Ngons"),
                               ("n_poles", "N poles"),
                               ("e_poles", "E poles"),
                               ("more_poles", "Poles > 5"),
                               ("isolated_verts", "Isolated verts")
                               )

            row = ob_box.row()
            row.label(text=f"Verts: {mc_object._verts} -- Faces: "
                           f"{mc_object._faces} -- Triangles: "
                           f"{mc_object._tris} ")

            row_stats = ob_box.row()
            split = row_stats.split(factor=0.02)
            split.separator()
            col_1 = split.column()
            col_2 = split.column()

            for i, checker in enumerate(checker_options):
                identifier, name = checker
                col = col_1 if i<=2 else col_2
                if getattr(mesh_check, identifier):
                    if hasattr(mc_object, f'_{identifier}'):
                        count = getattr(mc_object, f'_{identifier}').count
                    else:
                        count = mc_object._poles.count(identifier)
                    col.label(
                            text=f"{name}: {count}")


def register():
    bpy.types.VIEW3D_PT_overlay.append(mesh_check_panel)

def unregister():
    bpy.types.VIEW3D_PT_overlay.remove(mesh_check_panel)
