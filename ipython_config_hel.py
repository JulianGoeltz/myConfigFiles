import sys
sys.path.append('/wang/users/jgoeltz/cluster_home/pip_files/')

from powerline.bindings.ipython.since_5 import PowerlinePrompts
c = get_config()
c.TerminalInteractiveShell.simple_prompt = False
c.TerminalInteractiveShell.prompts_class = PowerlinePrompts
