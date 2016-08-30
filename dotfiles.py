import os, json, sys
from datetime import datetime
from jinja2 import Environment, PackageLoader

TEMPLATE_FOLDER = 'templates'
BUILD_FOLDER = 'dotfiles'
BACKUP_FOLDER = 'backups'
MODULE_FOLDER = 'modules'
CONFIG_FILE = 'config.json'

def get_paths(home_dir, bin_dir, template_file):
	dot_file = template_file.replace("_", ".", 1)
	home_path = "%s/%s" % (home_dir, dot_file)
	build_path = "%s/%s/%s" % (bin_dir, BUILD_FOLDER, template_file)
	backup_path = "%s/%s" % (bin_dir, BACKUP_FOLDER)
	return home_path, build_path, backup_path, dot_file


def copy_file(source, destination):
	os.system("cp -R %s %s" % (source, destination))

def build_template(environment, config, template_file, build_path):
	try:
		template = environment.get_template(template_file)
		variables = config.get(template_file, {})
		content = template.render(**variables)
	except:
		with open("%s/%s" % (TEMPLATE_FOLDER, template_file), 'r') as f:
			content = f.read();
	with open(build_path, 'w') as f:
		f.write(content)

def backup_file(home_path, backup_path, dot_file, stamp):
	if os.path.exists(home_path):
		backup_folder = '%s/%s' % (backup_path, stamp)
		if not os.path.exists(backup_folder):
			os.mkdir(backup_folder)
		backup_file_path = "%s/%s" % (backup_folder, dot_file)
		print "Backing up: %s" % backup_file_path
		copy_file(home_path, backup_file_path)

def main():
	env = Environment(loader=PackageLoader('dotfiles', TEMPLATE_FOLDER))

	template_files = os.listdir(TEMPLATE_FOLDER)
	bin_dir = sys.argv[1]
	home_dir = sys.argv[2]
	backup_number = len(os.listdir(BACKUP_FOLDER)) + 1
	stamp = "%d.%s" % (backup_number, datetime.now().isoformat())

	with open(CONFIG_FILE) as f:
		config = json.load(f)

	for template_file in template_files:
		home_path, build_path, backup_path, dot_filename = get_paths(home_dir, bin_dir, template_file)

		build_template(env, config, template_file, build_path)
		backup_file(home_path, backup_path, dot_filename, stamp)
		if os.path.exists(home_path):
			os.system("rm -r %s" % home_path)
		print "Generating symlinks from %s to %s" % (home_path, build_path)
		os.symlink(build_path, home_path)

	# Installing modules
	modules = os.listdir(MODULE_FOLDER)

	for module in modules:
		module_path = "%s/%s/%s" % (bin_dir, MODULE_FOLDER, module)
		files = os.listdir(module_path)
		for dot_file in files:
			home_path, build_path, backup_path, dot_filename = get_paths(home_dir, bin_dir, dot_file)
			# copy module file to build path
			copy_file("%s/modules/%s/%s" % (bin_dir, module, dot_file), build_path)
			backup_file(home_path, backup_path, dot_filename, stamp)
			if os.path.exists(home_path):
				os.system("rm -r %s" % home_path)
			os.symlink(build_path, home_path)

if __name__ == "__main__":
	main()
