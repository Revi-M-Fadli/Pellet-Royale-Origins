//  Evolution Simulator of Food-seeking Steering Bots
//  Revi M Fadli
//  Steering:  Vector Acceleration Differential Drive
//  Food: Two separate, uniformly-blinking foods
//  Version: 0.999...

/*  
    Use it, steal it, do whatever you want. 
    But please learn something, and probably make your own version. Then upload documentation/YouTube video and notify me.
    
    Critics and suggestions are very welcome
*/

color blue         = color(0,0,255);
color red          = color(255,0,0);
boolean cuteMode   = false;

//  Parameters control panel
int POP            = 50;
int eatcount       = 0;
int HP             = 20;
int clones         = 4;

int world_speed = 1;

ArrayList<Steero> steeries;
BlinkFood[] foods = new BlinkFood[2];




void setup(){
  size(1000,600);
  strokeWeight(2);
  cuteMode = true;
  
  steeries = new ArrayList<Steero>();
  for(int i = 0; i<POP; i++){
    PVector pos = new PVector(random(1)*width, random(1)*height);
    /*PVector pos = PVector.random2D();
    pos.mult(0.2*height*random(1));
    pos.x += width*0.5;
    pos.y += height*0.5;
    */
    
    PVector clrv = new PVector(random(1), random(1));
    SimpleResNet brian = new SimpleResNet();
    brian.init();
    steeries.add(new Steero(pos, clrv, brian));
  }
  foods[0] = new BlinkFood(blue);
  foods[1] = new BlinkFood(red);
}

void draw(){
  background(0);
  
  //run simulation loop multiple times
  for(int steps = 0; steps<world_speed; steps++){ // start worldstep
    //birds update
    int lastsize = steeries.size()-1;
    //println(lastsize);
      for(int i = lastsize; i>=0; i--){
      Steero s = steeries.get(i);
      //brains and positions
      s.getInpData(foods);
      
      //process inputs with brain, and output results to actuators
      s.think();
      
      //check food collision
      if (s.dist_sq1<s.d_sq){
        foods[0].nibbled();
        for(int j = 0; j<clones; j++){
          steeries.add(s.clone());
        }
        eatcount++;
        //println(s.input[1]);
      }
     
      if (s.dist_sq2<s.d_sq){
        foods[1].nibbled();
        for(int j = 0; j<clones; j++){
          steeries.add(s.clone());
        }
        eatcount++;
        //println(s.input[3]);
      }
      
      s.update();
    }  
    
        
    //check creature deletion
    for(int i = lastsize; i>=0; i--){
      Steero s = steeries.get(i);
      s.health -= eatcount;
      if (s.health<1){
        steeries.remove(i);
      }
    }
    
    //relocate food if eaten
    foods[0].relocIfEaten();
    foods[1].relocIfEaten();
    
    eatcount = 0;
  } // end of world step
  
  
  //display all items
  foods[0].display();
  foods[1].display();
  for(int i = 0; i<steeries.size(); i++){
    Steero s = steeries.get(i);
    s.display();
  }
  //println(steeries.size());
}

void keyPressed(){
   if (key == CODED) {
    if (keyCode == UP) {
      world_speed *= 2;
    } else if (keyCode == DOWN) {
      world_speed = 1;
    }
    String title = "Dual Food Seeker (World Speed: ";
    title += world_speed + ")";
    frame.setTitle(title);
   }
   
   if (key == 'b' || key == 'B') {
     foods[0].relocate();
   }
   if (key == 'r' || key == 'R') {
     foods[1].relocate();
   }
   if (key == 'c' || key == 'C') {
     if(cuteMode){
       strokeWeight(1);
       cuteMode = false;
     }else{
       strokeWeight(2);
       cuteMode = true;
     }
   }
   
}

float bounceBackMutate(float w, float str, float cap){
    w += randomGaussian()*str;
    
    if (w>cap){
      w = cap+cap-w;
      if (w<-cap){
        w = -cap;
      }
    }else if (w<-cap){
      w = -w-cap-cap;
      if (w>cap){
        w = cap;
      }
    }
    return w;
}

//Classes
class BlinkFood{
  PVector pos;
  int colore;
  int side = 10;
  
  public boolean eaten = false;
  
  BlinkFood(int col){
    pos = new PVector(random(1)*width, random(1)*height);
    colore = col;
  }
  
  void relocate(){
    pos.x = random(1)*width;
    pos.y = random(1)*height;
    println(pos.x, " ",pos.y," ", colore);
  }
  
  //display food
  void display(){
    stroke(255,223,0);
    fill(colore);
    rectMode(CENTER);
    rect(pos.x, pos.y, side, side);
  }
  
  void relocIfEaten(){
    if (eaten){
      relocate();
      eaten = false;
    }
  }
  
  public void nibbled(){
    eaten = true;
  }
}

class WeightMatrix{
  int in, out;
  float weights[][];
  float cap;
  
  WeightMatrix(int in_, int out_, float cap_){
    in = in_;
    out = out_;
    cap = cap_;
    weights = new float[out][in];
  }
  
  void init(){
    for(int i=0; i<out; i++){
      for(int j=0; j<in; j++){
        weights[i][j] = random(-cap, cap);
      }
    }
  }
    
  
  void fProp(float[] x, float[] y){
    float temp;
    for(int i=0; i<y.length; i++){
      temp = 0;
      for(int j=0; j<x.length; j++){
        temp += weights[i][j] * x[j];
      }
      y[i] = temp;
    }
  }
  
  void fPropAdd(float[] x, float[] y){
    for(int i=0; i<y.length; i++){
      for(int j=0; j<x.length; j++){
        y[i] += weights[i][j] * x[j];
      }
    }
  }
  
  void mutate(float str, float cap){
    for(int i=0; i<out; i++){
      for(int j=0; j<in; j++){
        weights[i][j] = bounceBackMutate(weights[i][j], str, cap);
      }
    }
  }
  
  float get(int i, int j){
    return weights[i][j];
  }
  
  void matCopy(WeightMatrix source){
    for(int i=0; i<out; i++){
      for(int j=0; j<in; j++){
        weights[i][j] = source.get(i,j);
      }
    }
  }
  
}

class Bias{
  float[] values;
  float cap;
  
  Bias(int lwidth, float cap_){
    values = new float[lwidth];
    cap = cap_;
  }
  
  void init(){
    for(int i=0; i<values.length; i++){
      values[i] = 0.5*random(-cap, cap);//randomGaussian();//
    }
  }
  
  float get(int i){
    return values[i];
  }
  
  void mutate(float str, float cap){
    for(int i=0; i<values.length; i++){
      values[i] = bounceBackMutate(values[i], str, cap);
    }
  }
  
  //  Deep copy source Bias values
  void biasCopy(Bias source){
    for(int i=0; i<values.length; i++){
      values[i] = source.get(i);
    }
  }
}
      


class SimpleResNet{
   int INPUTS = 8;
  int H1 = 9;
  int H2 = 3;
  int OUTPUTS = 2;
  
  float[] input;
  float[] hidden1;
  //float[] linsum;
  float[] hidden2;
  float[] output;
  
  WeightMatrix[] W;//W1,W2,W3,W4,W5;
  Bias bh1, bh2, bout;
  
  //  Neuroevolution hyperparameters
  float STR = 0.1;
  float W_CAP = 4;
  float B_CAP = 5;
  
  SimpleResNet(){
    input = new float[INPUTS];
    hidden1 = new float[H1];    
    //linsum = new float[OUTPUTS];   
    hidden2 = new float[H2];    
    output = new float[OUTPUTS];
    
    W = new WeightMatrix[5];
    W[0] = new WeightMatrix(INPUTS,OUTPUTS,W_CAP) ;
    W[1] = new WeightMatrix(INPUTS,H1,W_CAP) ;
    W[2] = new WeightMatrix(H1,OUTPUTS,W_CAP);
    W[3] = new WeightMatrix(OUTPUTS,H2,W_CAP);
    W[4] = new WeightMatrix(H2,OUTPUTS,W_CAP);
    
    bh1 = new Bias(H1, B_CAP);
    bh2 = new Bias(H2, B_CAP);
    bout = new Bias(OUTPUTS, B_CAP);
  }
  
  void init(){
    for(int i=0; i<5; i++){
      W[i].init();
    }
    bh1.init();
    bh2.init();
    bout.init();
  }
    
    
  
  float fastSigmo(float z){
    return z/(1.0+abs(z));
  }
  
  void process(){
    //inp->out
    W[0].fProp(input,output);
    //inp->h1
    W[1].fProp(input,hidden1);
    for(int i=0; i<hidden1.length; i++){
      hidden1[i] = fastSigmo(hidden1[i] + bh1.get(i));
    }
    //h1->out
    W[2].fPropAdd(hidden1,output);
    //out->h2
    W[3].fProp(output,hidden2);
    for(int i=0; i<hidden2.length; i++){
      hidden2[i] = fastSigmo(hidden2[i] + bh2.get(i));
    }
    //h2->out
    W[4].fPropAdd(hidden2,output);
    for(int i=0; i<output.length; i++){
      output[i] = fastSigmo(output[i] + bout.get(i));
    }
  }
  
  //neuroevolution functions
  void mutate(){
    for(int i=0; i<W.length; i++){
      W[i].mutate(STR,W_CAP);
    }
    bh1.mutate(STR,B_CAP);
    bh2.mutate(STR,B_CAP);
    bout.mutate(STR,B_CAP);
  }
  
  SimpleResNet duplicate(){
    SimpleResNet newBrain = new SimpleResNet();
    for(int i=0; i<W.length; i++){
      newBrain.W[i].matCopy(W[i]);
    }
    bh1.biasCopy(bh1);
    bh2.biasCopy(bh2);
    bout.biasCopy(bout);
    
    return newBrain;
  }
    

  //mathematical learning functions
}       


class Steero{
 PVector loc;
 PVector vel;
 PVector acc;
 
 PVector dir;
 
 float r_v, l_v;
 float vmax = 4;
 float k_theta = 0.15, k_decay = 0.975, k_acc = 0.1*vmax*(1 - k_decay);
 
 float radius = 8;
 float diameter = 2*radius;
 float d_sq = diameter * diameter;   //4 * radius * radius;
 float dist_sq1, dist_sq2;
 float half_dist;
 
 PVector colorvec;
 
 color warna;
 
 SimpleResNet brain;
 int health;
 
 Steero(PVector pos, PVector colorvec_, SimpleResNet brain_){
   brain = brain_;
   half_dist = 0.25*(width*width + height*height);
   
   colorvec = colorvec_;
   warna = vec2color(colorvec_);
   
   loc = pos;
   dir = PVector.random2D();
   dir.mult(5);
   acc = new PVector(0,0);
   vel = new PVector(0,0);
      
   r_v = 1;
   l_v = 1;
   
   health = HP;
 }
 
 void update(){   
   dir.rotate((l_v-r_v) * k_theta);
   acc = dir.copy();
   acc.mult((r_v+l_v) * k_acc);
   
   vel.mult(k_decay);
   vel.add(acc);
   loc.add(vel);
   
   checkEdges();
 }
 
 //display bot
 void display(){
   stroke(0);
   fill(warna);
   ellipse(loc.x,loc.y,diameter,diameter);
   fill(0);
   stroke(2);
   line(loc.x,loc.y,loc.x + dir.x, loc.y+dir.y);
 }
 
 void checkEdges() {
    if (loc.x > width) {
      loc.x = 0;
    } else if (loc.x < 0) {
      loc.x = width;
    }
 
    if (loc.y > height) {
      loc.y = 0;
    } else if (loc.y < 0) {
      loc.y = height;
    }
 }
 
 Steero clone(){
   SimpleResNet childBrain =  brain.duplicate();//new SimpleResNet();//
   //childBrain.mutate();
   PVector childloc = loc.copy();
   PVector childcolor = colorvec.copy();
   Steero child = new Steero(childloc, childcolor, childBrain);
   child.mutate();
   //return new Steero(childloc, childcolor, childBrain);
   return child;
 }     
 
 void mutate(){
   brain.mutate();
   half_dist = abs(half_dist + randomGaussian());
   
   float cx = map(colorvec.x, 0, 1, -1, 1);
   float cy = map(colorvec.y, 0, 1, -1, 1);
   cx = bounceBackMutate(cx,0.1,1);
   cy = bounceBackMutate(cy,0.1,1);
   colorvec.x = map(cx, -1, 1, 0, 1);
   colorvec.y = map(cy, -1, 1, 0, 1);
   warna = vec2color(colorvec);
 }
 
 void getInpData(BlinkFood[] foodArr){
   PVector d1 = PVector.sub(loc,foodArr[0].pos);
   PVector d2 = PVector.sub(loc,foodArr[1].pos);
   
   dist_sq1 = distSquared(d1);
   float theta1 = signedAngle(dir,d1);
   dist_sq2 = distSquared(d2);
   float theta2 = signedAngle(dir,d2);
   float theta3 = signedAngle(dir,vel);
   
   brain.input [0] = dsq2inp(dist_sq1);
   brain.input [1] = theta1;
   brain.input [2] = dsq2inp(dist_sq2);
   brain.input [3] = theta2;
   brain.input [4] = vel.mag()/vmax;
   brain.input [5] = theta3;
   brain.input [6] = loc.x/width;
   brain.input [7] = loc.y/height;
   
   //println(brain.input[4]);
 }
 
 void think(){
   brain.process();
   r_v = brain.output[0];
   l_v = brain.output[1];
   //println(r_v, " ", l_v);
 }
 
 float distSquared(PVector d){
   return d.x*d.x + d.y*d.y;
 }
 
 float dsq2inp(float dsq){
   return half_dist/(half_dist+dsq);
 }
 
 float signedAngle(PVector a, PVector b){
   float theta = b.heading()-a.heading();
   theta = (theta>PI) ? theta-TAU : (theta<-PI) ? TAU+theta : theta;
   return theta/PI;
 }
 
 color vec2color(PVector colorvec){
      float colorsum = 1.0;
      float c1 = colorvec.x;
      colorsum -= c1;
      float c2 = colorsum*colorvec.y;
      colorsum -= c2;
      
      return color(c2*255,c1*255,colorsum*255);
    }
}