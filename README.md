# Pellet-Royale-Origins
## What is it?
An Alife/machine learning neo-Braitenberg ecosystem simulator with neural network agents. 

Agents/creatures compete to catch one of two "food" pellets that respawn randomly everytime one is eaten. The agent that manages to do so gets to reproduce,
while the oldest agent is destroyed. Reproduction is currently asexual, with Gaussian mutations

The agents have ResNet-inspired neural networks as their "brain". The inputs are the distances and relative angles towards food 1 and 2, their own speed and relative heading, and normalized
x and y coordinates. The map wraps around like a torus.

## So... how does it work?

## Interesting results so far

## To-do:
1. Very Soon
  1.1 Optimize a bit, replace copy() with set()
  1.2 Pop size 64
  1.3 Circular buffer to alleviate crashing(probably caused by heap bloating due to new objects keep beign created)
  
2. Soon
  2.1 Nesterov momentum steering
  2.2 Rock-paper-scissors food
  2.3 Leapfrog food
  
  
3. Someday, Interesting Ideas
  3.1 Sexual reproduction
  3.2 Traditional RL or evolution strategies
