# Pellet-Royale-Origins
## What is it?
An Alife/machine learning neo-Braitenberg ecosystem simulator with neural network agents. 

It is currently a minimum viable product(MVP) that I rolled out ASAP to feel more productive, so stay tuned for updates!

## So... how does it work?
Agents/creatures compete to catch one of two "food" pellets that respawn randomly everytime one is eaten. The agent that manages to do so gets to reproduce,
while the oldest agent is destroyed. Reproduction is currently asexual, with Gaussian mutations

The agents have ResNet-inspired neural networks as their "brain". The inputs are the distances and relative angles towards food 1 and 2, their own speed and relative heading, and normalized
x and y coordinates. The map wraps around like a torus.

## Interesting results so far
Although the task of seeking food through relative polar coordinate is easy(negative angle? just output positive turn rate, and vice versa), and despite the simple environment(only one food, no terrain variation, creatures don't even directly interact with each other) several emergent behavior were observed:

#### Stopping until food is close enough
Despite not interacting directly, a creature obtaining a pellet makes it respawn in another part of the map. This means that slower creatures would hopelessly spin in place if they keep going after food all the time. Thus, in that situation it is better to wait in place until some better/faster creatures eat enough far away pellets that they eventually respawn closer due to the uniform distribution. Even the fastest creatures can be beaten with this strategy.

Eventually, there exists mutualism between these kinds of creature, where ones from distant edges of the map wait for each other to eat and make the pellet respawn closer to them

#### Crossing world boundaries if it's closer
Although this was partly intentional(I added absolute coordinates to help creatures from getting lost when encountering world boundaries), creatures still need to learn how to exploit these teleports by themselves. Quite satisfyingly, they did.

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
