#!zsh

source /home/$USER/venvs/pytorch/bin/activate
ipython -c "import numpy as np, matplotlib.pyplot as plt, torch, jax, jax.numpy as jnp" -i
