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


bl_info = {
    "name": "Mesh Check GPU edition",
    "description": "",
    "author": "Legigan Jeremy AKA Pistiwique, 1COD",
    "version": (0, 3, 0),
    "blender": (2, 83, 0),
    "location": "View3D => Header => Overlays",
    "wiki_url": "",
    "tracker_url": "https://discord.gg/ctQAdbY",
    "category": "Object"}


modules = (
    "preferences",
    "properties",
    "ui"
)

for mod in modules:
    exec(f"from . import {mod}")


def cleanse_modules():
    """search for persistent modules of the plugin in blender python sys.modules and remove them"""

    import sys

    all_modules = sys.modules
    all_modules = dict(
        sorted(all_modules.items(), key=lambda x: x[0]))  # sort them

    for k in all_modules.keys():
        if k.startswith(__name__):
            del sys.modules[k]

    return None


def register():

    for mod in modules:
        exec(f"{mod}.register()")

    bpy.types.Object.mesh_check_statistics = bpy.props.BoolProperty(
            name="Toggle Visibility",
            default=False)


def unregister():
    del bpy.types.Object.mesh_check_statistics

    for mod in reversed(modules):
        exec(f"{mod}.unregister()")

    cleanse_modules()
