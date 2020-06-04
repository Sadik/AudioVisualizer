import beads.*;
import java.util.Arrays; 

AudioContext ac;
PowerSpectrum ps;

final String DIRTITLE = "30RamEid";
final String TITLE = "Ramadan Plenum #Eid";
final String DATE  = "24. Mai 2020";
double VIDEO_LENGHT = -1; // add a second

final int WIDTH = 1280;
final int HEIGHT = 720;
final int MAXBARS = 15;
int waitStep;
PImage bgImage;
long startTime;

boolean DEBUG = false;
boolean VERBOSE = false;

void setup()
{
  // BASICS
  size(1280, 720);
  bgImage = loadImage("backgroundImage.png");
  background(bgImage);
  noCursor();
  frameRate(5);

  // AUDIO
  ac = new AudioContext();
  selectInput("Select an audio file:", "fileSelected");
}

void fileSelected(File selection) {
  String audioFileName = selection.getAbsolutePath();
  Sample sample = SampleManager.sample(audioFileName);
  SamplePlayer player = new SamplePlayer(ac, sample);
  if (DEBUG) {
    println("Audi file has sample rate: ", player.getSampleRate());
  }
  Gain g = new Gain(ac, 2, 0.2);
  g.addInput(player);
  ac.out.addInput(g);
  // Analyse signal, build an analysis chain
  ShortFrameSegmenter sfs = new ShortFrameSegmenter(ac);
  sfs.addInput(ac.out);
  beads.FFT fft = new beads.FFT();
  ps = new PowerSpectrum();
  sfs.addListener(fft);
  fft.addListener(ps);
  ac.out.addDependent(sfs);
  //and begin
  ac.start();
  startTime = System.currentTimeMillis(); //fetch starting time
  VIDEO_LENGHT = sample.getLength() + 1000;
  if (DEBUG)
    println("Duration = " + sample.getLength() + " ms");
  println("Starting!");
}

void draw()
{ 
  if (!DEBUG && VERBOSE) {
    println("Rendering läuft noch ", (VIDEO_LENGHT - (System.currentTimeMillis() - startTime))/1000, " s");
  }
  drawBackground();
  if(ps == null) {
    saveFrame("export/"+DIRTITLE+"/Video_######.png");
    return;
  }
  double sum = 0;
  double avg = 0;
  float[] features = ps.getFeatures();
  if (features != null) {
    for (int i = 0; i < features.length; i++) {
      //println("features[",i,"]: ", features[i]);
      sum += features[i];
    }
    if (features.length > 0)
      avg = sum / features.length;
    else
      avg = 0;
    if (DEBUG) {
      println("features.length: ", features.length);
      println("sum: ", sum);
      println("avg: ", avg);
    }
  }
  int level = getLevel(avg);
  
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

  saveFrame("export/"+DIRTITLE+"/Video_######.png");
  if((System.currentTimeMillis() - startTime) > VIDEO_LENGHT) {
    println("fertig!");
    exit();
  }
}

int getLevel(double avg) {
    double MAXVALUE = 8;
    if (avg > MAXVALUE) {
      return MAXBARS;
    }
    
    double percent = avg / MAXVALUE;
    double numberBars = MAXBARS * percent;
    if (DEBUG) {
      println("percent: ", percent);
      println("level: ", numberBars);
    }
    return (int) numberBars;
}

void drawBackground() {
  background(bgImage);
  PFont myFont = loadFont("Montserrat-Bold-48.vlw");
  //println(PFont.list());
  textFont(myFont, 88);
  fill(0, 102, 155);
  //textAlign(CENTER, CENTER);
  text(TITLE, WIDTH/10, 120);
  textSize(32);
  text(DATE, WIDTH/10, 160);
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
