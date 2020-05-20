
import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.sound.SoundFile;

Minim minim;
AudioPlayer jingle;
AudioInput input;
FFT fft;
int[][] colo=new int[300][3];
//AudioIn in;

final String TITLE = "Ramadan Plenum 25";
final String DATE  = "25. Mai 2020";
final String FILENAME = "25.Ram.mp3";
final long VIDEO_LENGHT = 903661; // add a second

final int WIDTH = 1280;
final int HEIGHT = 720;
int waitStep;
SoundFile file;
PImage bgImage;
long startTime;

boolean DEBUG = false;

void setup()
{
  size(1280, 720);
  background(0);
  noCursor();
  frameRate(24);
  file = new SoundFile(this, FILENAME);
  if (DEBUG)
    println("Duration= " + file.duration() + " seconds");
  file.play();
  startTime = System.currentTimeMillis(); //fetch starting time
  println("Starting!");
  bgImage = loadImage("backgroundImage.png");
  
  minim = new Minim(this);
  input = minim.getLineIn(Minim.STEREO,2048,22000);
  fft = new FFT(input.bufferSize(), input.sampleRate());
 
  waitStep = 0;
}


void draw()
{ 
  //image(img, WIDTH*2/3, HEIGHT/2);
  waitStep++;
  if(waitStep < 0){
    return;
  }
  if (DEBUG) {
    println("Rendering läuft noch ", (VIDEO_LENGHT - (System.currentTimeMillis() - startTime))/1000, " s");
  }
  waitStep = 0;
  drawBackground();

  fft.forward(input.mix);

  float highest = 0;
  for(int i = 0; i < fft.specSize(); i++)
  {
    if (fft.getBand(i) > highest) {
      highest = fft.getBand(i);
    }
  }
  int level = (int) highest / 30;

  clear();
  for (int i = 0; i < level; i++) {
    fill(255);
    stroke(132,0,4);
    noFill();
    strokeWeight(10);
    int x = WIDTH / 2 + 100 + i*30;
    int y = HEIGHT/2-10;
    float start = -PI / 6;
    float end = PI / 6;
    int boxW = 120 + i*2;
    int boxH = 200 + i*50;
    arc(x, y, boxW, boxH, start, end);
    x = WIDTH / 2 - 100 - i*30;
    start = 5*PI/6;
    end = PI + PI/6;
    arc(x, y, boxW, boxH, start, end);
  }
  saveFrame("Video_######.png");
  if((System.currentTimeMillis() - startTime) > VIDEO_LENGHT) {
    println("fertig!");
    exit();
  }
}

void drawBackground() {
  background(bgImage);
  PFont myFont = loadFont("Montserrat-Bold-48.vlw");
  //println(PFont.list());
  textFont(myFont, 88);
  fill(0, 102, 155);
  //textAlign(CENTER, CENTER);
  text(TITLE, WIDTH/7, 120);
  textSize(32);
  text(DATE, WIDTH/7, 160);
}

/**
 * 
 */
void clear() {
  stroke(255);
  noFill();
  strokeWeight(10);
  for (int i = 0; i < 10; i++) {
    int x = WIDTH / 2 + 100 + i*30;
    int y = HEIGHT/2-10;
    float start = -PI / 6;
    float end = PI / 6;
    int boxW = 120 + i*2;
    int boxH = 200 + i*50;
    arc(x, y, boxW, boxH, start, end);
    x = WIDTH / 2 - 100 - i*30;
    start = 5*PI/6;
    end = PI + PI/6;
    arc(x, y, boxW, boxH, start, end);
  }
}
