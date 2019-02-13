class Graph{
  String Title="Plot";
  String xLabel="x - Label";
  String yLabel="y - Label";
 
  color GraphColor;
  color BackgroundColor=color(0,45,90); 
  color StrokeColor=color(0,170,255);
  color TextColor=color(180);
 
  int xDiv=5,yDiv=5;
  int xPos,yPos; 
  int Width,Height; 
  
  float yMax=1024, yMin=0;
  float xMax=10, xMin=0;
  float yMaxRight=1024,yMinRight=0;
  
  Graph(int x, int y, int w, int h,color k, 
    String title, String x_l, String y_l, float valMax, float valMin) { 
    xPos = x;
    yPos = y;
    Width = w;
    Height = h;
    GraphColor = k;
    Title = title;
    xLabel = x_l;
    yLabel = y_l;
    yMax = valMax;
    yMin = valMin;
  }
  void DrawAxis(){
    fill(BackgroundColor); 
    color(0);stroke(StrokeColor);strokeWeight(1);
    int t=50;
    
    rect(xPos-t*1.6,yPos-t,Width+t*2.5,Height+t*2);
    textAlign(CENTER);textSize(10);
    float c=textWidth(Title);
    fill(BackgroundColor); color(0);stroke(0);strokeWeight(1);

    fill(255);
    text(Title,xPos+Width/2,yPos-37);
    
    
    textAlign(CENTER);textSize(10);    
    text(xLabel,xPos+Width/2,yPos+Height+t/2);
    rotate(-PI/2);
    text(yLabel,-yPos-Height/2,xPos-t*1.6+20);
    rotate(PI/2);
    
    textSize(10); noFill(); stroke(0); smooth();strokeWeight(1);
    
    
    // Edges
    line(xPos-3,yPos+Height,xPos-3,yPos);
    line(xPos-3,yPos+Height,xPos+Width+5,yPos+Height);
    
    stroke(200);
    if(yMin<0)
      line(xPos-7, yPos+Height-(abs(yMin)/(yMax-yMin))*Height, xPos+Width, yPos+Height-(abs(yMin)/(yMax-yMin))*Height);

    stroke(0);
    // Displaying x axis
    for(int x=0; x<=xDiv; x++){
      line(float(x)/xDiv*Width+xPos-3,yPos+Height,       //  x-axis Sub devisions    
           float(x)/xDiv*Width+xPos-3,yPos+Height+5);     
      textSize(10);                                      // x-axis Labels
      String xAxis=str(xMin+float(x)/xDiv*(xMax-xMin));  // the only way to get a specific number of decimals 
      String[] xAxisMS=split(xAxis,'.');                 // is to split the float into strings
      fill(255);
      text(xAxisMS[0]+"."+xAxisMS[1].charAt(0),          // ...
           float(x)/xDiv*Width+xPos-3,yPos+Height+15);   // x-axis Labels
    }


    // Displaying y axis

    for(int y=0; y<=yDiv; y++){
      line(xPos-3,float(y)/yDiv*Height+yPos,                // ...
            xPos-7,float(y)/yDiv*Height+yPos);              // y-axis lines 
      textAlign(RIGHT);fill(20);
      String yAxis=str(yMin+float(y)/yDiv*(yMax-yMin));     // Make y Label a string
      String[] yAxisMS=split(yAxis,'.');         // Split string
      fill(255);
      text(yAxisMS[0]+"."+yAxisMS[1].charAt(0),             // ... 
           xPos-15,float(yDiv-y)/yDiv*Height+yPos+3);       // y-axis Labels 
    }
    stroke(0);
  }

  void LineGraph(float[] x ,float[] y) {  
    for (int i=0; i<(x.length-1); i++){
    strokeWeight(2);stroke(GraphColor);noFill();smooth();
    line(xPos+(x[i]-x[0])/(x[x.length-1]-x[0])*Width,
        yPos+Height-(y[i]/(yMax-yMin)*Height)+(yMin)/(yMax-yMin)*Height,
        xPos+(x[i+1]-x[0])/(x[x.length-1]-x[0])*Width,
        yPos+Height-(y[i+1]/(yMax-yMin)*Height)+(yMin)/(yMax-yMin)*Height);
    }
  }
};
