import sys
import subprocess
from enum import EnumMeta, Enum

class MyEnumMeta(EnumMeta):

	def __contains__(self, other):
		try:
			self(other)
		except ValueError:
			return False
		else:
			return True

class UpgradeType(Enum, metaclass=MyEnumMeta):
	NONE = 'none'
	PATCH = 'patch'
	MINOR = 'minor'
	MAJOR = 'major'

class ProductType(Enum, metaclass=MyEnumMeta):
	NONE = 'none'
	IOM = 'iom'
	PWA = 'pwa'
	ICM_REPLICATION = 'icm-replication'
	ICM = 'icm'
	ICM_AS = 'icm-as'
	ICM_WEB = 'icm-web'

def handle_subprocess_error(subprocess_result, error_message):
    if subprocess_result.returncode != 0:
        print(error_message)
        print(f"Return code {subprocess_result.returncode}")
        print("STDERR:")
        print(str(subprocess_result.stderr, "UTF-8"))
        print("STDOUT:")
        print(str(subprocess_result.stdout, "UTF-8"))
        exit(1)

def main(argv):
	chart = ProductType.NONE
	upgrade = UpgradeType.NONE

	for label in argv:
		if label in ProductType:
			chart = ProductType(label)

	for label in argv:
		if label in UpgradeType:
			upgrade = UpgradeType(label)

	if upgrade == UpgradeType.NONE or chart == ProductType.NONE:
		print("No need for a version bump detected")
		exit(0)

	print(f"Bumping version of \'{chart.value}\' to next \'{upgrade.value}\' value.")
	bumpver_process = subprocess.run(f"bump2version {upgrade.value}",
                                     shell=True,
                                     cwd=f"./charts/{chart.value}",
                                     capture_output=True)
	handle_subprocess_error(bumpver_process, "Could not execute version bump.")


if __name__ == "__main__":
	main(sys.argv[1:])
