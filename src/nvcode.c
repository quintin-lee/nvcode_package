#include <libgen.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define NVIM_APPNAME "nvcode"

char *bin_dir = NULL;
char config_home[PATH_MAX] = {0};
char data_home[PATH_MAX] = {0};
char runtime_home[PATH_MAX] = {0};
char state_home[PATH_MAX] = {0};

void set_environment(void) {
  int ret = 0;
  char path[PATH_MAX]; // PATH_MAX is defined in limits.h
  char *env_name_config_home = "XGD_CONFIG_HOME";
  char *env_name_data_home = "XGD_DATA_HOME";
  char *env_name_runtime_dir = "XGD_RUNTIME_DIR";
  char *env_name_state_home = "XGD_STATE_HOME";
  char *env_name_nvim_appname = "NVIM_APPNAME";

  ret = readlink("/proc/self/exe", path, PATH_MAX);
  path[ret] = 0;
  bin_dir = dirname(path);
  // printf("%s\n", bin_dir);

  sprintf(config_home, "%s/../config", bin_dir);
  sprintf(data_home, "%s/../share", bin_dir);
  sprintf(runtime_home, "%s/../tmp", bin_dir);
  sprintf(state_home, "%s/../state", bin_dir);

  setenv(env_name_nvim_appname, NVIM_APPNAME, 0);
  setenv(env_name_config_home, config_home, 0);
  setenv(env_name_data_home, data_home, 0);
  setenv(env_name_runtime_dir, runtime_home, 0);
  setenv(env_name_state_home, state_home, 0);
}

int main(int argc, char **argv) {
  char cmd[1024] = {0};

  set_environment();

  sprintf(cmd, "%s/nvim", bin_dir);
  execv(cmd, argv);
  return 0;
}
