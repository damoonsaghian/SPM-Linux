# https://lazka.github.io/pgi-docs/Gtk-4.0/classes/ListBoxRow.html
# https://lazka.github.io/pgi-docs/Gio-2.0/classes/ListStore.html
# https://lazka.github.io/pgi-docs/Gio-2.0/classes/ListModel.html
# https://lazka.github.io/pgi-docs/Gdk-4.0/classes/AppLaunchContext.html
# https://lazka.github.io/pgi-docs/Gtk-4.0/classes/FlowBoxChild.html
# https://lazka.github.io/pgi-docs/index.html#Gio-2.0/classes/AppInfo.html

# https://github.com/yucefsourani/python-gtk4-examples/tree/main/listbox_searchbar
# https://github.com/yucefsourani/python-gtk4-examples/tree/main/stack_flowbox_css_provider
# https://github.com/GNOME/pygobject/blob/master/examples/demo/demos/flowbox.py
# https://github.com/GNOME/pygobject/tree/master/examples/demo/demos/TreeView
# https://github.com/GNOME/pygobject/blob/master/examples/demo/demos/IconView/iconviewbasics.py
# https://github.com/GNOME/pygobject/blob/master/examples/demo/demos/IconView/iconviewedit.py
# https://github.com/GNOME/pygobject/blob/master/examples/demo/demos/Entry/search_entry.py
# https://github.com/Ulauncher/Ulauncher/blob/v6/ulauncher/modes/apps/app_mode.py
# https://github.com/Ulauncher/Ulauncher/blob/v6/ulauncher/modes/apps/launch_app.py
# https://github.com/otsaloma/catapult/blob/master/catapult/plugins/apps.py

# the first item is "settings" that opens a vte window running "settings" command

# an item for screenshot
# grim wl-clipboard
# grim -o "$$HOME/.cache/screen.png" | wl-copy --type text/uri-list "file://$$HOME/.cache/screen.png"

import subprocess
import re

import gi
gi.require_version('Gtk', '4.0')
from gi.repository import GLib, Gio, Gtk

class AppLauncher:
	def __init__(self):
		self.widget = Gtk.Box(
			orientation = Gtk.Orientation.VERTICAL,
			spacing = 5,
			margin_top = 5,
			margin_bottom = 5,
			margin_start = 5,
			margin_end = 5
		)
		
		search_entry = Gtk.SearchEntry()
		search_entry.connect('search_changed', self.on_search_changed)
		search_entry.connect('activate', self.on_activate)
		search_entry.connect('notify:has-focus', lambda _: search_entry.delete_text(0, -1))
		self.widget.append(search_entry)
		
		self.apps_list = Gio.ListStore(Gio.AppInfo)
		
		self.update_apps_list()
		Gio.AppInfoMonitor.get().connect('changed', self.update_apps_list)
		
		self.selected_item = self.apps_list.get_item(0)
		
		self.apps_flowbox = Gtk.FlowBox(
			orientation = Gtk.Orientation.HORIZONTAL,
			column_spacing = 5,
			row_spacing = 5,
			margin_top = 5, margin_bottom = 5, margin_start = 5, margin_end = 5,
			activate_on_single_click = True,
			focusable = False
		)
		self.apps_flowbox.bind_model(self.apps_list, self.create_widget)
		
		flowbox_child = self.apps_flowbox.get_child_at_index(0)
		if flowbox_child:
			self.apps_flowbox.select_child(flowbox_child)
		
		self.apps_flowbox.connect('activate', self.on_item_click)
		
		self.widget.append(Gtk.ScrolledWindow(child=self.apps_flowbox))
	
	def on_search_changed(self, search_entry):
		if len(search_entry) == 0:
			self.selected_item = self.apps_list.get_item(0)
			flowbox_child = self.apps_flowbox.get_child_at_index(0)
			if flowbox_child:
				self.apps_flowbox.select_child(flowbox_child)
			return
		
		search_pattern = search_entry.text.replace(" ", ".*")
		i = 0
		
		while true:
			item :Gio.AppInfo|None = self.apps_list.get_item(i)
			if not item:
				break
			if re.compile(search_pattern).match(item.get_name()):
				self.selected_item = item
				flowbox_child = self.apps_flowbox.get_child_at_index(i)
				if flowbox_child:
					self.apps_flowbox.select_child(flowbox_child)
				break
			i+=1
	
	def on_activate(self):
		app_item = self.selected_item
		
		app_name = app_item.get_name()
		subprocess.run([
			'swaymsg',
			f'[app_id=codev] move workspace {app_name}; workspace {app_name}' 
		])
		
		if not subprocess.run(['swaymsg', '[floating] focus']):
			subprocess.run(['swaymsg', 'exec ' + app_item.get_executable()])
		
		subprocess.run(['swaymsg', '[app_id=swapps] move scratchpad'])
		
		# if entry starts with a punctuation character, run it as a command
	
	def compare_apps(self, app1 :Gio.AppInfo, app2 :Gio.AppInfo):
		app1_name = app1.get_name()
		app2_name = app2.get_name()
		if app2_name > app1_name:
			return -1
		if app1_name > app2_name:
			return 1
		return 0
	
	def update_apps_list(self):
		self.apps_list.remove_all()
		for app in Gio.AppInfo.get_all():
			if app.should_show():
				self.apps_list.insert_sorted(app, self.compare_apps)
		
		settings_app = Gio.AppInfo.create_from_commandline("settings")
		self.apps_list.insert(0, settings_app)
		
	def create_widget(self, app_item :Gio.AppInfo):
		app_name = app_item.get_name()
		
		label = Gtk.Label(
			label = app_name,
			justify = Gtk.Justification.CENTER,
			width_chars = 20
		)
		
		icon = app_item.get_icon()
		if not icon:
			if app_name = "settings":
				icon = Gio.ThemedIcon("applications-system-symbolic")
			else:
				icon = Gio.ThemedIcon("")
		icon_image = Gtk.Image.new_from_gicon(icon)
		
		widget = Gtk.Box(orientation = Gtk.Orientation.VERTICAL, spacing = 5)
		widget.append(icon_image)
		widget.append(label)
		return widget
	
	def on_item_click(self, apps_flowbox :Gtk.FlowBox):
		selected_child :Gtk.FlowBoxChild = apps_flowbox.get_selected_children()[0]
		index = selected_child.get_index()
		self.selected_item = self.apps_list.get_item(index)
		self.on_activate()


class MyApp(Gtk.Application):
	def do_activate(self):
		window = self.get_windows()[0]
		if not window:
			window = Gtk.ApplicationWindow(application=app)
			window.set_child(AppLauncher().widget)
			
			subprocess.run(['swaymsg', 'mode swapps'])
			
			# don't close swapps, if workspace is empty
			
			# escape: swaymsg "[app_id=swayapps] move scratchpad"
			
			# super or alt+tab: swaymsg workspace back_and_forth
			
			# when window is unfocused:
			# swaymsg mode default
			# swaymsg "[con_id=__focused__] focus" || codev || swaymsg "[app_id=swapps] focus"
			subprocess.run(['swaymsg', 'mode default'])
			subprocess.run(['swaymsg', "[con_id=__focused__] focus"]) or
				subprocess.run(['codev']) or
				subprocess.run(['swaymsg', "[app_id=swapps] focus"])
		
		self.win.present()
		subprocess.run(['swaymsg', "[app_id=swapps] focus"])

MyApp(application_id='swapps').run(None)

# an item that runs swaycap
