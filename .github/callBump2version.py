import sys
import subprocess
from enum import EnumMeta, Enum
from functools import total_ordering

class MyEnumMeta(EnumMeta):

  def __contains__(self, other):
    try:
      self(other)
    except ValueError:
      return False
    else:
      return True

@total_ordering
class UpgradeType(Enum, metaclass=MyEnumMeta):
  PATCH = 'patch'
  MINOR = 'minor'
  MAJOR = 'major'
  def __lt__(self, other):
    if self.__class__ is other.__class__:
      order = {
        UpgradeType.PATCH: 0,
        UpgradeType.MINOR: 1,
        UpgradeType.MAJOR: 2
      }
      return order[self] < order[other]
    return NotImplemented

class ProductType(Enum, metaclass=MyEnumMeta):
  PWA = 'pwa'
  ICM_REPLICATION = 'icm-replication'
  ICM = 'icm'
  ICM_AS = 'icm-as'
  ICM_JOB = 'icm-job'
  ICM_WEB = 'icm-web'

# key is a ProductType
# value is a list of ProductType which depend on the key
dependencies = {
  ProductType.PWA: [],
  ProductType.ICM_REPLICATION: [],
  ProductType.ICM: [ProductType.ICM_REPLICATION],
  ProductType.ICM_AS: [ProductType.ICM],
  ProductType.ICM_JOB: [],
  ProductType.ICM_WEB: [ProductType.ICM]
}

def handle_subprocess_error(subprocess_result, error_message):
    if subprocess_result.returncode != 0:
        print(error_message)
        print(f"Return code {subprocess_result.returncode}")
        print("STDERR:")
        print(str(subprocess_result.stderr, "UTF-8"))
        print("STDOUT:")
        print(str(subprocess_result.stdout, "UTF-8"))
        exit(1)

def bumpVersion(chart, bump):
  print(f"Bumping version of \'{chart.value}\' to next \'{bump.value}\' value.")
  bumpver_process = subprocess.run(f"bump-my-version --allow-dirty bump {bump.value}",
                                     shell=True,
                                     cwd=f"./charts/{chart.value}",
                                     capture_output=True)
  handle_subprocess_error(bumpver_process, "Could not execute version bump.")

# recursively adds all dependents of chart to dict, overriding the previous value
# if upgrade is bigger than the existing entry
def addAllDependencies(chart: ProductType, upgrade: UpgradeType, dict: dict):
  if chart not in dict or dict[chart] < upgrade:
    dict[chart] = upgrade
  for dep in dependencies[chart]:
    addAllDependencies(dep, upgrade, dict)

# argv must be in the format "chart1:upgrade1 chart2:upgrade2"
# dependent charts are computed and do not have to be specified
# note: this cannot be used for the iom chart since they don't use bump2version
def main(argv):
  # parse arguments and figure out dependencies
  deps = dict()
  for arg in argv:
    split_arg = arg.split(":")

    if split_arg[0] in ProductType and split_arg[1] in UpgradeType:
      product = ProductType(split_arg[0])
      upgrade = UpgradeType(split_arg[1])
      addAllDependencies(product, upgrade, deps)
    else:
      raise Exception("Illegal input: " + arg)
  # do the actual updates
  for chart, upgrade in deps.items():
    bumpVersion(chart, upgrade)

if __name__ == "__main__":
  main(sys.argv[1:])
