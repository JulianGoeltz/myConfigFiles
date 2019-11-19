import sys

# check whether we are in a virtualenvironment
# https://stackoverflow.com/questions/1871549/determine-if-python-is-running-inside-virtualenv
# if hasattr(sys, 'prefix') and hasattr(sys, 'prefix') and sys.prefix == sys.base_prefix:
#     try:
#         ## old style
#         # c = get_config()
#         # c.InteractiveShellApp.extensions = [
#         #     'powerline.bindings.ipython.post_0_11'
#         # ]
# 
#         # use the following
#         from powerline.bindings.ipython.since_5 import PowerlinePrompts
#         c = get_config()
#         c.TerminalInteractiveShell.simple_prompt = False
#         c.TerminalInteractiveShell.prompts_class = PowerlinePrompts
#         # Shortcut style to use at the prompt. 'vi' or 'emacs'.
#         c.TerminalInteractiveShell.editing_mode = 'vi'
# 
#         # Set the editor used by IPython (default to $EDITOR/vi/notepad).
#         c.TerminalInteractiveShell.editor = 'vim'
# 
#         c.TerminalInteractiveShell.highlighting_style = 'monokai'
#     except ImportError:
#         print("######### No powerline available")
# else:
#     print("######### Not using powerline in venvs")

c = get_config()
c.TerminalInteractiveShell.editing_mode = 'vi'
# c.TerminalInteractiveShell.highlighting_style = 'monokai'

import pkg_resources
if pkg_resources.get_distribution("prompt_toolkit").version == '2.0.10' and\
   pkg_resources.get_distribution("powerline-status").version == '2.7':
    print("with the current versions of powerline and prompt_toolkit powerline doesnt work")
else:
    print("#####################################")
    print("#####################################")
    print("###### new versions in powerline &prompt_toolkit, check whether it works again")
    print("#####################################")
    print("#####################################")
