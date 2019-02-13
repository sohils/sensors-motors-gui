import controlP5.*;
import processing.serial.*;

Serial port;
ControlP5 cp5;

String read;
// Colours:
// Dark Blue: (0,45,90)
// Selected: (0,170,255)
// Lightest: (0,116,217)

Graph stepperAngleGraph = new Graph(80, 450, 375, 150, color (0,170,255), "Angle moved by the Stepper", "Time (s)", "Angle moved (degrees)", 360, -360);
Graph dcAngleGraph = new Graph(580, 450, 375, 150, color (0,170,255), "RPM of DC Motor", "Time (s)", "RPM", 165, -165);
//Graph LineGraph3 = new Graph(700, 350, 200, 100, color (0,170,255));
float[][] stepperGraphValues = new float[1][100];
float[][] dcAngleGraphValues = new float[1][100];
float[] lineGraphSampleNumbers = new float[100];

int val = 0;
int frame_height = 650;
int frame_width = 1000;
int baseColor = 50, highlightColor = 50;

Slider ir_slider;
Slider dc_mouth;
Slider dc_angle_slider;
Slider dc_rpm_slider;
Toggle slot_toggle;
Toggle manual_toggle;
Knob dc_angle_knob;
Knob dc_rpm_knob;
Knob servo_knob;
Textfield stepper_text;
Textfield servo_text;

Textlabel main_title; 
Textlabel ir_units;
Textlabel servo_unit;
Textarea log_title; 
Textlabel stepper_title;
Textlabel servo_title;
Textlabel dc_title;

int sensor_state = 0;
boolean gotCommand = false;
String command = "";

void lockUnlock(){
  // S1
  //ir_slider.lock();
  stepper_text.setFocus(false).lock();
  
  // S2
  //slot_toggle.lock();
  //servo_knob.lock();
  servo_text.setFocus(false).lock();
  
  // S3 & S4
  dc_angle_knob.lock();
  dc_rpm_knob.lock();
  
  if(manual_toggle.getValue() == 0){
    return;
  }
  switch(sensor_state%4){
    case 0:{
      //ir_slider.unlock();
      stepper_text.unlock().setFocus(true);
      break;
    }
    case 1:{
      //slot_toggle.unlock();
      //servo_knob.unlock();
      servo_text.unlock().setFocus(true);
      break;
    }
    case 2:{
      dc_angle_knob.unlock();
      break;
    }
    case 3:{
      dc_rpm_knob.unlock();
      break;
    }
  }
}

void parseExecuteCommand(String commandString){
  
  // Parse Command
  String commands[] = split(commandString,'_');
  int command;
  float value = 0;
  
  if(commands[0].length() != 1){
    println(commands[0]);
    println("Command is not of length 1");
    return;
  }
  command = Integer.parseInt(commands[0]);
  value = float(commands[1]);
  //println("Execting command " + command + " " + value);
  // Execute Command
  switch(command)
  {
    case 0: {
      sensor_state = int(value);
      lockUnlock();
      println("Sensor state change: " +value);
      break;
    }
    case 1: {
      servo_knob.setValue(value);
      break;
    }
    case 2: {
      slot_toggle.setValue(int(value)==0);
      break;
    }
    case 3: {
      ir_slider.setValue(value);
      break;
    }
    case 4: {
      updateGraph(0, stepperGraphValues, value);
      break;
    }
    case 5: {
      dc_angle_slider.setValue(value);
      break;
    }
    case 6: {
      dc_rpm_slider.setValue(value);
      updateGraph(0, dcAngleGraphValues, value);
      break;
    }
  }
  
}

void setup() {
  
  PFont font = createFont("Menlo",12);
  
  
  surface.setTitle("Realtime plotter");
  size(1000, 650);
  
  String portName="";
  String portNames[] = Serial.list(); //change the 0 to a 1 or 2 etc. to match your port
  for(int i =0; i < portNames.length; i++){
    if(portNames[i].contains("cu.usb"))
      portName = portNames[i];
  }
  portName = portNames[0];
  println(portName);  
  port = new Serial(this, portName, 9600);
  
  cp5 = new ControlP5(this);
  
  // Main title
  main_title = cp5.addTextlabel("titleLabel")
              .setText("H#SH Control")
              .setPosition(40,20)
              .setFont(createFont("Menlo",36))
              .setColor(color(200,0,0));
  
  // Manual to Sensor Toggle
  manual_toggle = cp5.addToggle("Mode")
      .setPosition(40,75)
      .setSize(80,50)
      .setValue(false)
      .setColorCaptionLabel(color(20,20,20))
      .setColorBackground(color(0,75,150))
      .setFont(font)
      .setMode(ControlP5.SWITCH)
      .onChange(new CallbackListener() { 
    public void controlEvent(CallbackEvent theEvent) {
      port.write("0&"+(int)theEvent.getController().getValue()+"\n");
      log_title.setText("Changing mode to "+ (((int)theEvent.getController().getValue()==0)?"Sensor Controlled":"GUI Control") +".\n");
      lockUnlock();
      //println("0&"+(int)theEvent.getController().getValue()+"\n");
    }
  });
  
  // Logger
  log_title = cp5.addTextarea("txt")
            .setPosition(140,75)
            .setSize(150,50)
            .setText("hello\n")
            .setFont(createFont("Menlo",12))
            .setLineHeight(14)
            .setColor(color(200))
            .setColorBackground(color(20))
            .setColorForeground(color(20));
            ;
  
  
  // Stepper Motor and IR Sensor
  ir_slider = cp5.addSlider("infraredRanger")
      .setPosition(width/6 - 100, 300)
      .setSize(200, 50)
      .setRange(0,100)
      .setColorCaptionLabel(color(20,20,20))
      .setFont(font)
      .setSliderMode(Slider.FLEXIBLE)
      .lock();
  ir_units = cp5.addTextlabel("cm").setText("(CM)")
        .setPosition(width/6 - 100, 355);
  
  cp5.getController("infraredRanger")
  .getCaptionLabel()
  .align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE)
  .setPaddingX(0);
  
  stepper_text = cp5.addTextfield("Set_Stepper_Angle")
     .setPosition(width/6 - 100,200)
     .setSize(200,50)
     .setFocus(true)
     .setColorActive(color(255,255,255))
     .setColor(color(255,0,0))
     .setColorBackground(color(0,75,150))
     .setColorCaptionLabel(color(20,20,20))
     .setFont(font);
  
  // Servo Motor and Slot Sensor
  slot_toggle = cp5.addToggle("Slot")
      .setPosition(width/2-40,300)
      .setSize(80,50)
      .setColorCaptionLabel(color(20,20,20))
      .setFont(font)
      .lock();
      
  servo_text = cp5.addTextfield("Set_Servo_Angle")
     .setPosition(width/2-100,50)
     .setSize(200,50)
     .setFocus(true).setFont(createFont("arial",20))
     .setColor(color(255,0,0))
     .setColorActive(color(255,255,255))
     .setColorCaptionLabel(color(20,20,20))
     .setColorBackground(color(0,75,150))
     .setFont(font)
     .setMin(0)
     .setMax(360);
     
  servo_unit = cp5.addTextlabel("servo_unit").setText("(degrees)")
      .setPosition(width/2-23, 270);
     
  servo_knob = cp5.addKnob("ServoAngle")
      .setRange(0,180)
       .setValue(50)
       .setPosition(width/2-50 ,150)
       .setRadius(50)
       .setColorCaptionLabel(color(20,20,20))
       .setViewStyle(1)
       .setShowAngleRange(true)
       .lock()
       .onChange(new CallbackListener() { 
    public void controlEvent(CallbackEvent theEvent) {
      println("m&"+theEvent.getController().getValue());
    }
  })
       .setFont(font);
   
  // DC Motor and Potentiometer
  dc_angle_knob = cp5.addKnob("DC_Motor_Angle")
      .setRange(0,360)
       .setValue(0)
       .setPosition(9*width/12-40, 110)
       .setRadius(50)
       .setNumberOfTickMarks(10)
       .setColorCaptionLabel(color(20,20,20))
       .setColorBackground(color(0,75,150))
       .setColorForeground(color(255))
       .setViewStyle(2)
       .setFont(font)
       ;
  dc_angle_slider = cp5.addSlider("Current_DC_Angle")
      .setPosition(9*width/12-40, 70)
      .setSize(100, 20)
      .setRange(0,1024)
      .setColorCaptionLabel(color(20,20,20))
      .setFont(font)
      .setNumberOfTickMarks(10)
      .snapToTickMarks(false)
      .lock();
  cp5.getController("Current_DC_Angle")
  .getCaptionLabel()
  .align(ControlP5.RIGHT, ControlP5.TOP_OUTSIDE)
  .setPaddingX(0);
       
  dc_rpm_knob = cp5.addKnob("DC_Motor_RPM")
      .setRange(-165,165)
       .setValue(0)
       .setPosition(11*width/12-60, 110)
       .setRadius(50)
       .setNumberOfTickMarks(10)
       .setColorCaptionLabel(color(20,20,20))
       .setColorBackground(color(0,75,150))
       .setColorForeground(color(255))
       .setViewStyle(1)
       .setFont(font)
       ;
  dc_rpm_slider = cp5.addSlider("Current_DC_RPM")
      .setPosition(11*width/12-60, 70)
      .setSize(100, 20)
      .setRange(-165,165)
      .setColorCaptionLabel(color(20,20,20))
      .setFont(font)
      .lock();
  
  cp5.getController("Current_DC_RPM")
  .getCaptionLabel()
  .align(ControlP5.RIGHT, ControlP5.TOP_OUTSIDE)
  .setPaddingX(0);    
  
  dc_mouth = cp5.addSlider("H#SH Original")
        .setPosition(5*width/6 - 100, 300)
        .setSize(200, 50)
        .setRange(0,100)
        .setValue(40)
        .setColorCaptionLabel(color(20,20,20))
        .setSliderMode(Slider.FLEXIBLE)
        .setFont(font)
        .lock();
  cp5.getController("H#SH Original")
  .getCaptionLabel()
  .align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE)
  .setPaddingX(0);
  
  for (int i=0; i<stepperGraphValues.length; i++) {
    for (int k=0; k<stepperGraphValues[0].length; k++) {
      stepperGraphValues[i][k] = 0;
      if (i==0)
        lineGraphSampleNumbers[k] = k;
    }
  } 
}


public void Set_Stepper_Angle(String value){
  value.trim();
  boolean isNumber = value.matches("-?[0-9]+[.]?[0-9]*");
  if(!isNumber){
    log_title.setText("The value entered is not a number.\n");
    return;
  }
  if(-360<=float(value) && float(value)<=360){
    port.write("1&"+value+"\n");
    log_title.setText("Input value is "+value+"\n");
  }
  else
    log_title.setText("The number entered is not within range.\n");
}

public void Set_Servo_Angle(String value){
  value.trim();
  boolean isNumber = value.matches("-?[0-9]+[.]?[0-9]*");
  if(!isNumber){
    log_title.setText("The text entered is not a number.\n");
    return;
  }
  if(0<=float(value) && float(value)<=180){
    port.write("2&"+value+"\n");
    log_title.setText("Input value is "+value+"\n");
  }
  else
    log_title.setText("The number entered is not within range.\n");
}

public void DC_Motor_Angle(float value){
  port.write("3&"+value+"\n");
  log_title.setText("Setting DC Motor angle to "+value+"\n");
}

public void DC_Motor_RPM(float value){
  port.write("4&"+value+"\n");
  log_title.setText("Setting DC Motor speed to "+value+"\n");
}

void updateGraph(int i, float[][] lineGraphValues, float value){
  // Update the value of the Graph.
  try {
    for (int k=0; k<lineGraphValues[i].length-1; k++) {
       lineGraphValues[i][k] = lineGraphValues[i][k+1];
    }
    lineGraphValues[i][lineGraphValues[i].length-1] = value;
  }
  catch (Exception e) {}
}

void draw() {
  //lockUnlock();
  String cmd;
  if(gotCommand){
    cmd = command;
    command = "";
    gotCommand = false;
    parseExecuteCommand(cmd);
  }
  
  background(200); 
  stroke(color(0,170,255));
  
  line(width/3,0,width/3,400);
  line(width/3,400,2*width/3,400);
  line(2*width/3,0,2*width/3,400);
  
  highlightColor = (manual_toggle.getValue() == 0)?60:80;
    
  
  fill(0,baseColor + ((sensor_state%4==0)?highlightColor:0));stroke(0);strokeWeight(0);
  rect(width/6-125,150,250,225);
  fill(0,baseColor + ((sensor_state%4==1)?highlightColor:0));stroke(0);strokeWeight(0);
  rect(width/2-125,25,250,350);
  rect(width/2+125,100,20,100);
  rect(width/2-145,100,20,100);
  fill(0,baseColor + (((sensor_state%4==2) || (sensor_state%4==3))?highlightColor:0));stroke(0);strokeWeight(0);
  rect(5*width/6-150,50,300,325);
  rect(5*width/6-50,30,100,20);
  
  // Update the value of the Graph.
  //updateGraph(i, stepperGraphValues);
  //updateGraph(i, dcAngleGraphValues);
  
  //// Update dummy values.
  //if(val%512==0){
  //    sensor_state++;
  //  if(sensor_state == 3)
  //    sensor_state = 0;
  //  lockUnlock();
  //}
  //val ++;
  //if (val >1024)
  //  val = 0;
    
  // draw the line graphs
  stepperAngleGraph.DrawAxis();
  dcAngleGraph.DrawAxis();
  //LineGraph3.DrawAxis();
  for (int j=0;j<stepperGraphValues.length; j++) {
    if (true)
      stepperAngleGraph.LineGraph(lineGraphSampleNumbers, stepperGraphValues[j]);
      dcAngleGraph.LineGraph(lineGraphSampleNumbers, dcAngleGraphValues[j]);
      //LineGraph3.LineGraph(lineGraphSampleNumbers, lineGraphValues[j]);
  }
  
}

void serialEvent(Serial port) {
  read = port.readStringUntil('\n');
  if(read!=null){
    println(read);
  }
  if(read != null){
    if(read.charAt(0)=='0'){
      parseExecuteCommand(read);
      return;
    }
    //println(read);
    command = read;
    gotCommand = true;
  }
  
}
