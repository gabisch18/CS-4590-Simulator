import processing.video.*;

import guru.ttslib.*;


import beads.*;
import org.jaudiolibs.beads.*;
import controlP5.*;

ControlP5 p5;

Button perpBtn;
Button parallelBtn;
Button reverseBtn;
Button breakBtn;
Button interModeBtn;
Slider currSpeedSldr;
Slider2D currDistSldr;
Knob currWheelKnb;

Scenario scenario1;
Scenario scenario2;
Scenario scenario3;
Scenario scenario4;

Scenario currScenario;

SamplePlayer base;

//TTS Audio
String perpTTS = "Perpendicular Parking";
String parallelTTS = "Parallel Parking";
String reverseTTS = "Reverse Parking";
String interModeTTS = "Interactive Mode";
String breakTTS = "Break now.";

TextToSpeechMaker ttsMaker; 

Glide masterGlide;
Gain masterGain;
Glide masterWaveGlide;
Gain masterWaveGain;

int waveCount = 20;
float baseFrequency = 432.0;
Glide[] waveFrequency = new Glide[waveCount];
WavePlayer[] waveTone = new WavePlayer[waveCount];
Gain[] waveGain = new Gain[waveCount];

boolean playingSample;
boolean playMovie;

BiquadFilter filter;
Glide filterGlide;

Glide musicRateGlide;

//to use this, copy notification.pde, notification_listener.pde and notification_server.pde from this sketch to yours.
//Example usage below.

//name of a file to load from the data directory
String eventDataJSON2 = "smarthome_party.json";
String eventDataJSON1 = "smarthome_parent_night_out.json";

//Videos
String m;
Movie perpMovie;
Movie parallelMovie;
Movie reverseMovie;

void setup() {
  size(750,600);
  p5 = new ControlP5(this);
  
  ac = new AudioContext(); //ac is defined in helper_functions.pde
  
  playMovie = false;
  m = "0";
  
  perpMovie = new Movie(this, "PerpParkingVid.mov");
  parallelMovie = new Movie(this, "ParallelParking.mov");
  reverseMovie = new Movie(this, "ReverseParking.mov");

  
  //EDIT THESE!!!!!
  scenario1 = new Scenario("scenario1History.json", "Scenario1", 0.0, new float[]{0, 0}, 0.0);
  scenario2 = new Scenario("scenario2History.json", "Scenario2", 0.0, new float[]{0, 0}, 0.0);
  scenario3 = new Scenario("scenario3History.json", "Scenario3", 0.0, new float[]{0, 0}, 0.0);
  scenario4 = new Scenario("scenario4History.json", "Scenario4", 0.0, new float[]{0, 0}, 0.0);
  
  currScenario = new Scenario(scenario4);
  playingSample = false;
  
  base = getSamplePlayer("synth.wav");
  base.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  base.setKillOnEnd(false);
  
  musicRateGlide = new Glide(ac, 0, 500);
  base.setRate(musicRateGlide);

  
  masterGlide = new Glide(ac, 1.0, 200);
  masterGlide.setValue(0.5);
  masterGain = new Gain(ac, 1, masterGlide);
  
  masterWaveGlide = new Glide(ac, 1.0, 200);
  masterWaveGlide.setValue(0.5);
  masterWaveGain = new Gain(ac, 1, masterWaveGlide);
  
  //this will create WAV files in your data directory from input speech 
  //which you will then need to hook up to SamplePlayer Beads
  ttsMaker = new TextToSpeechMaker();
  
  ttsExamplePlayback(interModeTTS); //see ttsExamplePlayback below for usage
  
  
  float waveIntensity = 1.0;
  float diff;
  
  
  filterGlide = new Glide(ac, 10.0, 0.5f);
  filter = new BiquadFilter(ac, BiquadFilter.LP, filterGlide, 0.5f);
  
  filter.addInput (base);
  
  
  masterGain.addInput(filter);
  masterGain.addInput(masterWaveGain);
  ac.out.addInput(masterGain);
  
  //UI
  perpBtn = p5.addButton("perpendicularParking")
    .setPosition(30,420)
    .setSize(150,20)
    .setLabel("Perpendicular Parking")
    .activateBy((ControlP5.RELEASE));

    
  parallelBtn = p5.addButton("parallelParking")
    .setPosition(30,460)
    .setSize(150,20)
    .setLabel("Parallel Parking")
    .activateBy((ControlP5.RELEASE));

 
  reverseBtn = p5.addButton("reverseParking")
    .setPosition(30,500)
    .setSize(150,20)
    .setLabel("Reverse Parking")
    .activateBy((ControlP5.RELEASE));
    
  interModeBtn = p5.addButton("interactiveMode")
    .setPosition(30,540)
    .setSize(150,20)
    .setLabel("Interactive Mode")
    .activateBy((ControlP5.RELEASE));
    
  breakBtn = p5.addButton("break")
    .setPosition(550,150)
    .setSize(162,20)
    .setLabel("Break")
    .activateBy((ControlP5.RELEASE));
    
  currSpeedSldr = p5.addSlider("currSpeedSlider")
    .setSliderMode(Slider.FLEXIBLE)
    .setPosition(420,350)
    .setSize(20,200)
    .setRange(0, 10) //20, 15000
    //.setNumberOfTickMarks(30)
    //.showTickMarks(true)
    //.snapToTickMarks(true)
    .setValue(5)
    .setLabel("Current Speed (mph)");
    
  currDistSldr = p5.addSlider2D("currDistSlider")
    .setPosition(550,225)
    .setSize(162, 324) //108, 216
    //.setMinMax(-90,-180,90,180)
    .setMaxX(10)
    .setMaxY(10)
    .setMinX(-10)
    .setMinY(-10)
    .setValue(0,0)
    .setLabel("Current Distance (feet)");
    
  currWheelKnb = p5.addKnob("currWheelKnob")
    .setViewStyle(Knob.ELLIPSE)
    .setPosition(235, 430)
    .setRadius(60)
    .setAngleRange(PI*2)
    .setRange(-180, 180)
    .setLabel("Wheel Rotation (degrees)");
    
  ac.start();
}

public void setPlaybackRate(float rate, boolean immediately, SamplePlayer music) {
  double musicLength = music.getSample().getLength();
  if (music.getPosition() >= musicLength) {
    music.setToEnd();
  }

  if (music.getPosition() < 0) {
    music.reset();
  }
  
  if (immediately) {
    musicRateGlide.setValueImmediately(rate);
  }
  else {
    musicRateGlide.setValue(rate);
  }
}

public void calculateWheelPlayback() {
  if (currScenario.getCurrRotation() == 0) {
    setPlaybackRate(1, true, base);
    return;
  }
  float val = currScenario.getCurrRotation();
  if (currScenario.getCurrRotation() > 0) {
    val = abs(currScenario.getCurrRotation());
    setPlaybackRate(val/180+1, true, base);
  } else {
    val = abs(currScenario.getCurrRotation());
    setPlaybackRate((180-val)/180, true, base);
  }
  
}


//Scenarios
void perpendicularParking(int value) {
  ttsExamplePlayback(perpTTS);
  m = "1";
  perpMovie.jump(0.0);
  
  //updateVals(plant2);
  base.setToLoopStart();
}

void parallelParking(int value) {
  ttsExamplePlayback(parallelTTS);
  m = "2";
  parallelMovie.jump(0.0);
  
  //updateVals(plant2);
  base.setToLoopStart();
}

void reverseParking(int value) {
  ttsExamplePlayback(reverseTTS);
  m = "3";
  reverseMovie.jump(0.0);
  
  //updateVals(plant2);
  base.setToLoopStart();
}

void interactiveMode(int value) {
  ttsExamplePlayback(interModeTTS);
  m = "0";
  
  //updateVals(plant2);
  base.setToLoopStart();
}

//Sliders/Knobs
public void currSpeedSlider(float value) {
  currScenario.setCurrSpeed(value);
  //calculateSpeedFilter();
  filter.setFrequency((value + 1) * 150);
}

public void currDistSlider(int value) {
  
}

public void currWheelKnob(int value) {
  currScenario.setCurrRotation(value);
  calculateWheelPlayback();
}

void draw() {
  //this method must be present (even if empty) to process events such as keyPressed()  
  background(0);
  if (m == "1") {
    image(perpMovie, 15, 0, 480, 300);
    perpMovie.loop();
  } else if (m == "2") {
    image(parallelMovie, 15, 0, 480, 300);
    parallelMovie.loop();
  } else if (m == "3" ) {
    image(reverseMovie, 15, 0, 480, 300);
    reverseMovie.loop();
  }
  stroke(#FFFFFF);
  line(631, 210, 631, 225);
  line(535, 387, 725, 387);
}

void ttsExamplePlayback(String inputSpeech) {
  //create TTS file and play it back immediately
  //the SamplePlayer will remove itself when it is finished in this case
  
  String ttsFilePath = ttsMaker.createTTSWavFile(inputSpeech);
  println("File created at " + ttsFilePath);
  
  //createTTSWavFile makes a new WAV file of name ttsX.wav, where X is a unique integer
  //it returns the path relative to the sketch's data directory to the wav file
  
  //see helper_functions.pde for actual loading of the WAV file into a SamplePlayer
  
  SamplePlayer sp = getSamplePlayer(ttsFilePath, true); 
  //true means it will delete itself when it is finished playing
  //you may or may not want this behavior!
  
  ac.out.addInput(sp);
  sp.setToLoopStart();
  sp.start();
  println("TTS: " + inputSpeech);
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}
