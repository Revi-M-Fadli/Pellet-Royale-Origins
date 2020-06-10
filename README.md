# Pellet-Royale-Origins
An Alife/machine learning neo-Braitenberg ecosystem simulator with neural network agents. 

Agents/creatures compete to catch one of two "food" pellets that respawn randomly everytime one is eaten. The agent that manages to do so gets to reproduce,
while the oldest agent is destroyed.

The agents have ResNet-inspired neural networks as their "brain". The inputs are the distances and relative angles towards food 1 and 2, their own speed and relative heading, and normalized
x and y coordinates. The map wraps around like a torus.
