from IPython.terminal.prompts import Prompts
import os.path as osp
from pygments.token import Token
from prompt_toolkit.key_binding.vi_state import InputMode
import sys

c = get_config()
c.TerminalInteractiveShell.editing_mode = 'vi'


def is_venv():
    return (hasattr(sys, 'real_prefix') or
            (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix))


if is_venv():
    venv_name = osp.basename(sys.prefix) + "|"
else:
    venv_name = ""


class MyPrompt(Prompts):
    def in_prompt_tokens(self, cli=None):
        if cli is None:
            mode = ""
        elif cli.vi_state.input_mode == InputMode.INSERT:
            mode = 'ins|'
        else:
            mode = 'cmd|'
        return [
            (Token.Prompt, '['),
            (Token.Prompt, venv_name),
            (Token.Prompt, mode),
            (Token.PromptNum, str(self.shell.execution_count)),
            (Token.Prompt, ']> ')
        ]

    def out_prompt_tokens(self, cli=None):
        return [
        ]


c.TerminalInteractiveShell.prompts_class = MyPrompt
