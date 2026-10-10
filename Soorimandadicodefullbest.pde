// Navier-Stokes Singularity & Universal Kinematic Rotation Visualization
// Optimized for APDE (Android Processing) - High Performance & Crash Proof
// Combines fluid singularity visualization with a kinematic database.
// Now featuring universal Angular (Normal) and Tangential Velocity Vectors across all states.

CustomSlider stirSlider;
CustomSlider vectorSlider;
CustomSlider crossSectionSlider; 
SimpleButton nextButton;
SimpleButton toggleModeButton;   

int currentState = 0; 
float globalRotation = 0;
float stirSpeed = 0.02; 
float currentStir = 0; 

boolean isMultiSectionMode = true; 
float currentWhirlpoolSeed = 0; 

// Cached HUD Strings to prevent Memory Leaks/GC Stutters
String currentHudTitle = "";
String currentHudSubtitle = "";

// Database for all real-world rotating items
ArrayList<RotObj> rotDatabase = new ArrayList<RotObj>();

void setup() {
  size(displayWidth, displayHeight, P3D);
  orientation(PORTRAIT);
  textAlign(CENTER, CENTER);
  strokeWeight(3);
  
  // Setup Native Custom GUI Sliders
  crossSectionSlider = new CustomSlider(width/2 - 150, height - 290, 300, 45, 1, 15, 5, "Cross Sections", true);
  vectorSlider = new CustomSlider(width/2 - 150, height - 200, 300, 45, 2, 40, 12, "Tangential Vectors", true);
  stirSlider = new CustomSlider(width/2 - 150, height - 110, 300, 45, 0.01, 0.15, 0.05, "Angular Velocity (Omega)", false);
  
  // Setup Buttons
  nextButton = new SimpleButton(width - 220, 50, 180, 60, "Next State");
  toggleModeButton = new SimpleButton(40, height * 0.18, 240, 50, "Toggle Multi-Section");
  
  // Initialize Database & First State
  buildRotationDatabase();
  changeState(0);
}

void draw() {
  background(10, 15, 22); 
  lights();
  
  globalRotation += 0.005; 
  stirSpeed = stirSlider.getValue();
  currentStir += stirSpeed;

  // -----------------------------------------------------
  // Optimized State Machine Router
  // -----------------------------------------------------
  if (currentState == 0) drawStoryScreen();
  else if (currentState == 1) drawCupParaboloidScene();
  else if (currentState == 2) drawInfiniteSpikeScene();
  else if (currentState == 3) drawSingularityScene();
  else if (currentState == 4) drawCenteredWhirlpoolScene();
  else if (currentState == 5) drawWanderingIntersectionScene();
  else if (currentState == 6) drawTwinWhirlpoolsScene();
  else if (currentState == 7) drawOceanVortexScene();
  else if (currentState == 8) drawVariableRandomWhirlpoolScene();
  else {
    int dbIndex = currentState - 9;
    if (dbIndex >= 0 && dbIndex < rotDatabase.size()) {
      drawKinematicDatabaseScene(rotDatabase.get(dbIndex));
    }
  }

  // Draw cached HUD text
  if (currentState != 0) {
    drawHUD(currentHudTitle, currentHudSubtitle);
  }
  
  // Dynamic UI Rendering
  if (currentState == 5 || currentState == 8 || currentState >= 9) {
    toggleModeButton.display();
    if (isMultiSectionMode && !crossSectionSlider.isVisible) crossSectionSlider.show();
    else if (!isMultiSectionMode && crossSectionSlider.isVisible) crossSectionSlider.hide();
  }
  
  stirSlider.display();
  vectorSlider.display();
  crossSectionSlider.display();
  nextButton.display();
}

// --------------------------------------------------------
// State Transition Management (Prevents UI/GC lag)
// --------------------------------------------------------
void changeState(int newState) {
  currentState = newState;
  
  // Wrap around logic
  if (currentState >= 9 + rotDatabase.size()) { 
    currentState = 0; 
  }
  
  if (currentState == 8) currentWhirlpoolSeed = random(1000);
  
  // Reset UI Visibility Safely
  stirSlider.show(); 
  vectorSlider.show(); 
  crossSectionSlider.hide();
  
  // Set Cached Strings & specific UI rules
  if (currentState == 0) {
    stirSlider.hide(); vectorSlider.hide();
  } else if (currentState == 1) {
    currentHudTitle = "State 1: Normal Fluid Paraboloid"; currentHudSubtitle = "Smooth tangential vectors inside boundaries.";
  } else if (currentState == 2) {
    currentHudTitle = "State 2: Singularity / Infinite Spike"; currentHudSubtitle = "Yellow vectors show unbounded magnitude.";
  } else if (currentState == 3) {
    currentHudTitle = "State 3: Chaotic Tangled Whirlpools"; currentHudSubtitle = "Chaotic vector growth and turbulence.";
  } else if (currentState == 4) {
    currentHudTitle = "State 4: Centered Stable Whirlpool"; currentHudSubtitle = "Preparation for off-axis intersection.";
  } else if (currentState == 5) {
    currentHudTitle = "State 5: Yellow Whirlpool Envelope"; currentHudSubtitle = "Multi-section toggles available.";
  } else if (currentState == 6) {
    currentHudTitle = "State 6: Twin Interacting Vortices"; currentHudSubtitle = "Observe dual rotation patterns.";
  } else if (currentState == 7) {
    currentHudTitle = "State 7: Deep Ocean Vortex"; currentHudSubtitle = "Wide surface funneling into the abyss.";
  } else if (currentState == 8) {
    currentHudTitle = "State 8: Wild Distorted Vortex"; currentHudSubtitle = "Twists wildly along a multi-directional axis.";
  } else {
    int dbIndex = currentState - 9;
    RotObj obj = rotDatabase.get(dbIndex);
    currentHudTitle = "State " + currentState + " (" + obj.category + "): " + obj.name;
    currentHudSubtitle = obj.desc;
  }
}

// --------------------------------------------------------
// Inputs
// --------------------------------------------------------
void mousePressed() {
  stirSlider.checkPress(mouseX, mouseY);
  vectorSlider.checkPress(mouseX, mouseY);
  crossSectionSlider.checkPress(mouseX, mouseY);
  nextButton.checkPress(mouseX, mouseY);
  if (currentState == 5 || currentState == 8 || currentState >= 9) toggleModeButton.checkPress(mouseX, mouseY);
}

void mouseDragged() {
  stirSlider.checkDrag(mouseX);
  vectorSlider.checkDrag(mouseX);
  crossSectionSlider.checkDrag(mouseX);
}

void mouseReleased() {
  stirSlider.checkRelease();
  vectorSlider.checkRelease();
  crossSectionSlider.checkRelease();
  if (nextButton.checkRelease(mouseX, mouseY)) changeState(currentState + 1);
  if ((currentState == 5 || currentState == 8 || currentState >= 9) && toggleModeButton.checkRelease(mouseX, mouseY)) {
    isMultiSectionMode = !isMultiSectionMode;
  }
}

// --------------------------------------------------------
// Database Definition
// --------------------------------------------------------
class RotObj {
  String category, name, desc;
  float rTop, rBot, heightParam, speedMult;
  char axis; 
  RotObj(String c, String n, String d, float rt, float rb, float h, char ax, float sm) {
    category = c; name = n; desc = d; rTop = rt; rBot = rb; heightParam = h; axis = ax; speedMult = sm;
  }
}

void buildRotationDatabase() {
  // TOYS
  rotDatabase.add(new RotObj("Toys", "Wooden Spinning Top", "Gyroscopic stability on a tiny point.", 180, 10, 250, 'Z', 3.0));
  rotDatabase.add(new RotObj("Toys", "Beyblades", "High-speed spinning battle tops.", 150, 120, 60, 'Z', 4.0));
  rotDatabase.add(new RotObj("Toys", "Toy Motor & Gears", "Small DC electric motors turning gears.", 60, 60, 40, 'X', 5.0));
  rotDatabase.add(new RotObj("Toys", "Fidget Spinner", "Tri-lobed toy turning on ball bearings.", 140, 140, 20, 'Z', 2.5));
  rotDatabase.add(new RotObj("Toys", "Yo-yo", "Two discs spinning rapidly on a string.", 100, 100, 80, 'X', 3.0));
  rotDatabase.add(new RotObj("Toys", "Rubik's Cube Layer", "Rotating planar layers around a core.", 120, 120, 80, 'Y', 0.5));
  rotDatabase.add(new RotObj("Toys", "Merry-Go-Round", "Wide rotating platform for playgrounds.", 350, 350, 50, 'Z', 0.2));
  rotDatabase.add(new RotObj("Toys", "Ferris Wheel", "Giant vertical wheel with passenger cars.", 400, 400, 150, 'X', 0.1));
  rotDatabase.add(new RotObj("Toys", "Hula Hoop", "Thin ring spinning around the body.", 200, 200, 10, 'Z', 1.0));
  
  // APPLIANCES & HOUSEHOLD
  rotDatabase.add(new RotObj("Appliances", "Ceiling Fan", "Large blades circulating air downward.", 350, 350, 30, 'Z', 2.0));
  rotDatabase.add(new RotObj("Appliances", "Pedestal Fan", "Horizontal air propulsion fan.", 180, 180, 60, 'Z', 2.5)); 
  rotDatabase.add(new RotObj("Appliances", "Mixer Grinder Blade", "High RPM blades for blending.", 80, 80, 20, 'Z', 6.0));
  rotDatabase.add(new RotObj("Appliances", "Washing Machine Drum", "Spin cycle removing water via centrifugal force.", 250, 250, 300, 'X', 3.5));
  rotDatabase.add(new RotObj("Appliances", "Microwave Turntable", "Glass plate rotating for even heating.", 160, 160, 10, 'Z', 0.2));
  rotDatabase.add(new RotObj("Appliances", "Analog Clock Hands", "Hour, minute, second hands turning steadily.", 200, 200, 5, 'Z', 0.05));
  rotDatabase.add(new RotObj("Appliances", "Record Player", "Grooved platter spinning at 33/45 RPM.", 180, 180, 5, 'Z', 0.5));
  rotDatabase.add(new RotObj("Appliances", "Lazy Susan", "Rotating food tray on a dining table.", 250, 250, 15, 'Z', 0.2));
  rotDatabase.add(new RotObj("Appliances", "Rolling Pin", "Cylindrical pin flattening dough.", 40, 40, 300, 'X', 0.5));
  rotDatabase.add(new RotObj("Appliances", "Door Knob", "Twisting mechanical latch interface.", 50, 50, 60, 'X', 0.3));
  rotDatabase.add(new RotObj("Appliances", "Swivel Chair", "Office chair rotating on central cylinder.", 220, 220, 30, 'Z', 0.8));
  rotDatabase.add(new RotObj("Appliances", "Hair Dryer Fan", "Internal miniature fan for hot air exhaust.", 40, 40, 20, 'X', 5.0));

  // VEHICLES & TRANSPORT
  rotDatabase.add(new RotObj("Vehicles", "Bullock Cart Wheel", "Wooden spoked wheels on an axle.", 300, 300, 40, 'Y', 0.3));
  rotDatabase.add(new RotObj("Vehicles", "Car / Bike Wheel", "Rubber tire rotating on a metal rim.", 200, 200, 80, 'Y', 1.5));
  rotDatabase.add(new RotObj("Vehicles", "Steering Wheel", "Driver's control interface.", 150, 150, 20, 'Z', 0.4));
  rotDatabase.add(new RotObj("Vehicles", "Helicopter Rotor", "Massive main lifting propeller.", 450, 450, 20, 'Z', 3.0));
  rotDatabase.add(new RotObj("Vehicles", "Airplane Propeller", "Thrust-generating front blades.", 250, 250, 20, 'X', 4.0));
  rotDatabase.add(new RotObj("Vehicles", "Ship Propeller", "Underwater brass blades for propulsion.", 200, 10, 80, 'X', 1.5));

  // MACHINERY & TOOLS
  rotDatabase.add(new RotObj("Machinery", "Heavy Flywheel", "Stores rotational energy in engines.", 280, 280, 100, 'X', 2.0));
  rotDatabase.add(new RotObj("Machinery", "Power Drill Bit", "High-speed twisting metal cutter.", 15, 15, 180, 'Z', 5.0));
  rotDatabase.add(new RotObj("Machinery", "Circular Saw", "Toothed disc cutting through wood/metal.", 160, 160, 5, 'X', 4.5));
  rotDatabase.add(new RotObj("Machinery", "PC Cooling Fan", "Exhaust fan pushing heat out of cases.", 60, 60, 15, 'Z', 3.0));
  rotDatabase.add(new RotObj("Machinery", "Hard Disk Drive (HDD)", "Spinning magnetic platters at 7200 RPM.", 100, 100, 25, 'Z', 5.0));
  rotDatabase.add(new RotObj("Machinery", "Wind Turbine", "Massive blades converting wind to energy.", 400, 400, 40, 'X', 0.2));
  rotDatabase.add(new RotObj("Machinery", "Industrial Gears", "Interlocking teeth transferring torque.", 180, 180, 40, 'Y', 1.0));
  rotDatabase.add(new RotObj("Machinery", "Electric Generator", "Spinning electromagnets producing current.", 150, 150, 250, 'X', 2.5));
  rotDatabase.add(new RotObj("Machinery", "Lathe Machine", "Spins metal/wood rapidly for shaping.", 80, 80, 350, 'X', 3.0));

  // COSMIC
  rotDatabase.add(new RotObj("Cosmic", "Earth / Planets", "Rotating on axis creating day and night.", 300, 300, 300, 'Z', 0.1));
  rotDatabase.add(new RotObj("Cosmic", "Hurricane Vortex", "Massive meteorological storm system.", 400, 50, 400, 'Z', 1.5));
  rotDatabase.add(new RotObj("Cosmic", "Spiral Galaxy", "Millions of stars orbiting a central black hole.", 500, 500, 40, 'Z', 0.05));
}

// --------------------------------------------------------
// UNIVERSAL KINEMATIC RENDERING ENGINE
// --------------------------------------------------------
void drawKinematicDatabaseScene(RotObj obj) {
  pushMatrix();
  translate(width/2, height/2 + 50, -400);
  rotateX(PI / 3.0);
  rotateZ(globalRotation * 0.2); 
  
  if (obj.axis == 'X') rotateY(PI/2);
  else if (obj.axis == 'Y') rotateX(PI/2);

  float omegaMag = stirSpeed * obj.speedMult * 40.0; 
  int sections = isMultiSectionMode ? round(crossSectionSlider.getValue()) : 1;
  int vecs = round(vectorSlider.getValue());
  
  stroke(255, 255, 255, 100);
  strokeWeight(2);
  line(0, 0, -obj.heightParam/2 - 100, 0, 0, obj.heightParam/2 + 100);

  for(int s = 0; s < sections; s++) {
    float t = sections == 1 ? 0.5f : s / (float)(sections - 1);
    float zPos = map(t, 0, 1, obj.heightParam/2, -obj.heightParam/2);
    float radius = lerp(obj.rTop, obj.rBot, t);
    
    pushMatrix();
    translate(0, 0, zPos);
    noFill(); stroke(100, 180, 255, 150); strokeWeight(3);
    ellipse(0, 0, radius*2, radius*2);
    
    float omegaVisualScale = map(omegaMag, 0.4f, 30.0f, 50, 300);
    drawArrow(0, 0, 0, 0, 0, omegaVisualScale, color(0, 255, 100), 8); // Angular Central Normal Vector
    
    float thetaStep = TWO_PI / vecs;
    float timeOffset = frameCount * omegaMag * 0.01;
    for(int v = 0; v < vecs; v++) {
      float theta = (v * thetaStep) + timeOffset;
      float tx = -sin(theta), ty = cos(theta);
      float vMag = radius * omegaMag * 0.02;
      drawArrow(radius * cos(theta), radius * sin(theta), 0, tx * vMag, ty * vMag, 0, color(255, 50, 50), 5); // Tangential Vectors
    }
    popMatrix();
  }
  
  if (sections > 1) {
    stroke(100, 180, 255, 40); strokeWeight(1);
    for(float theta = 0; theta < TWO_PI; theta += PI/4) {
      beginShape(LINES);
      vertex(obj.rTop * cos(theta), obj.rTop * sin(theta), obj.heightParam/2);
      vertex(obj.rBot * cos(theta), obj.rBot * sin(theta), -obj.heightParam/2);
      endShape();
    }
  }
  popMatrix();
}

// --------------------------------------------------------
// Optimized Arrow Drawing (CRASH PROOF)
// --------------------------------------------------------
void drawArrow(float x, float y, float z, float dirX, float dirY, float dirZ, color c, float headSize) {
  stroke(c); fill(c); strokeWeight(2.5);
  line(x, y, z, x + dirX, y + dirY, z + dirZ);
  
  float len = sqrt(dirX*dirX + dirY*dirY + dirZ*dirZ);
  if (len > 0.001) { // Prevent Division by zero
    pushMatrix();
    translate(x + dirX, y + dirY, z + dirZ);
    float theta = atan2(dirY, dirX);
    // CRITICAL: constrain to prevent NaN crash in acos due to float precision
    float phi = acos(constrain(dirZ / len, -1.0f, 1.0f)); 
    rotateZ(theta);
    rotateY(phi);
    
    float arrowBase = -headSize * 2.5;
    noStroke();
    beginShape(TRIANGLES);
    vertex(0, 0, 0); vertex(-headSize, headSize, arrowBase); vertex(headSize, headSize, arrowBase);
    vertex(0, 0, 0); vertex(headSize, headSize, arrowBase); vertex(headSize, -headSize, arrowBase);
    vertex(0, 0, 0); vertex(headSize, -headSize, arrowBase); vertex(-headSize, -headSize, arrowBase);
    vertex(0, 0, 0); vertex(-headSize, -headSize, arrowBase); vertex(-headSize, headSize, arrowBase);
    endShape();
    popMatrix();
  }
}

// --------------------------------------------------------
// Fluid Dynamics Scenes
// --------------------------------------------------------
void drawStoryScreen() {
  hint(DISABLE_DEPTH_TEST); fill(255); textSize(displayDensity * 18);
  String story = "Fluid Dynamics & Kinematic Physics\n\n" +
                 "States 1-8: Navier-Stokes Singularity\n" +
                 "Observe how smooth fluid paraboloids can warp\n" +
                 "into infinite blowups and chaotic turbulent whirlpools.\n\n" +
                 "States 9-44: The Universal Rotation Database\n" +
                 "Explore 36 distinct rotating objects from Toys to Galaxies.\n" +
                 "[ GREEN VECTORS ]: Central Normal (Angular Velocity, \u03C9)\n" +
                 "[ RED VECTORS ]: Perimeter Tangential Velocity (v = \u03C9 x r)\n\n" +
                 "[ Tap NEXT STATE to begin ]";
  text(story, width/2, height/2);
  hint(ENABLE_DEPTH_TEST);
}

void drawCupParaboloidScene() {
  pushMatrix(); translate(width/2, height/2 + 50, -350); rotateX(PI / 2.6); rotateZ(globalRotation);
  float cTop = 320, cBot = 220, cH = 400;
  noFill(); stroke(255, 50); strokeWeight(2);
  pushMatrix(); translate(0, 0, cH); ellipse(0, 0, cTop*2, cTop*2); popMatrix();
  ellipse(0, 0, cBot*2, cBot*2);
  for(float a = 0; a < TWO_PI; a += PI/4) line(cBot*cos(a), cBot*sin(a), 0, cTop*cos(a), cTop*sin(a), cH);
  
  float maxD = map(stirSpeed, 0.01, 0.15, 20, 300), wZ = cH * 0.8, k = maxD / (cTop * cTop); 
  fill(0, 150, 255, 30); stroke(0, 180, 255, 80); strokeWeight(1.5);
  for (int i = 1; i <= 12; i++) {
    float r1 = map(i-1, 0, 12, 0, cTop * 0.95), r2 = map(i, 0, 12, 0, cTop * 0.95);
    beginShape(TRIANGLE_STRIP);
    for (int j = 0; j <= 30; j++) {
      float a = map(j, 0, 30, 0, TWO_PI);
      vertex(r1*cos(a), r1*sin(a), wZ - maxD + (k * r1 * r1)); vertex(r2*cos(a), r2*sin(a), wZ - maxD + (k * r2 * r2));
    }
    endShape();
  }
  float osc = (sin(frameCount * 0.04) + 1) * 0.5f; 
  float sliceZ = wZ - maxD + (maxD * osc), rad = sqrt((sliceZ - (wZ - maxD)) / k);
  
  pushMatrix(); translate(0, 0, sliceZ);
  noFill(); strokeWeight(6); stroke(50, 255, 100, 200); ellipse(0, 0, rad * 2, rad * 2);
  
  // Universal Kinematic Addition: Central Angular Normal Vector
  float globalOmega = map(stirSpeed, 0.01, 0.15, 50, 300);
  drawArrow(0, 0, 0, 0, 0, globalOmega, color(0, 255, 100), 8);
  
  int vecs = round(vectorSlider.getValue());
  for(int i = 0; i < vecs; i++) {
    float a = (i * TWO_PI / vecs) + currentStir * 2;
    float vMag = rad * map(stirSpeed, 0.01, 0.15, 0.05, 0.35);
    drawArrow(rad*cos(a), rad*sin(a), 0, -sin(a)*vMag, cos(a)*vMag, 0, color(255, 50, 50), 5); // Red Tangentials
  }
  popMatrix(); popMatrix();
}

void drawInfiniteSpikeScene() {
  pushMatrix(); translate(width/2, height * 0.65, -200); rotateX(PI / 2.6); 
  int numRings = 45; float baseRadius = 380;
  for (int i = 0; i < numRings; i++) {
    float t = i / (float)(numRings - 1); 
    float zPos = map(pow(t, 1.4), 0, 1, 0, -850); 
    float currentRadius = baseRadius * pow(1.0 - t, 2.5); 
    pushMatrix(); translate(0, 0, zPos); rotateZ(globalRotation * (1.0 + t * 2.0)); 
    noFill();
    
    if (i == 7) {
      stroke(255); strokeWeight(6); ellipse(0, 0, currentRadius * 2, currentRadius * 2);
      
      // Universal Kinematic Addition: Central Angular Normal Vector
      float globalOmega = map(stirSpeed, 0.01, 0.15, 50, 300);
      drawArrow(0, 0, 0, 0, 0, globalOmega, color(0, 255, 100), 8);
      
      int vecs = round(vectorSlider.getValue());
      for (int v = 0; v < vecs; v++) {
        float a = v * TWO_PI / vecs;
        drawArrow(currentRadius*cos(a), currentRadius*sin(a), 0, -sin(a) * map(stirSpeed, 0.01, 0.15, 40, 250), cos(a) * map(stirSpeed, 0.01, 0.15, 40, 250), 0, color(255, 50, 50), 6); // Red Tangentials
      }
    } else {
      stroke(150, 50, 200, map(t, 0, 1, 255, 50)); strokeWeight(2); ellipse(0, 0, currentRadius * 2, currentRadius * 2);
    }
    popMatrix();
  }
  popMatrix();
}

void drawSingularityScene() {
  pushMatrix(); translate(width/2, height/2, -500); rotateX(PI / 2.3); rotateZ(globalRotation * 0.5);
  float maxZ = 600, pinch = (cos(frameCount * 0.02) + 1) * 0.5f, eps = map(pinch, 0, 1, 1.0, 200.0); 
  pushMatrix(); noFill(); strokeWeight(5); stroke(50, 255, 100, map(eps, 200, 1, 100, 255)); ellipse(0, 0, eps * 2, eps * 2);
  
  // Universal Kinematic Addition: Central Angular Normal Vector
  float globalOmega = map(stirSpeed, 0.01, 0.15, 50, 300);
  drawArrow(0, 0, 0, 0, 0, globalOmega, color(0, 255, 100), 8);
  
  int vecs = round(vectorSlider.getValue());
  for(int i = 0; i < vecs; i++) {
    float a = (i * TWO_PI / vecs) + (frameCount * 0.1); 
    float vMag = map(eps, 200, 1, 20, 150) * map(stirSpeed, 0.01, 0.15, 0.5, 2.0); 
    drawArrow(eps*cos(a), eps*sin(a), 0, -sin(a)*vMag, cos(a)*vMag, 0, color(255, 50, 50), 5); // Red Tangentials
  }
  popMatrix();
  for (int i = 0; i < 90; i++) {
    float bA = i * TWO_PI / 90; noFill(); strokeWeight(2.5);
    boolean isTop = (i % 3 == 0), isBot = (i % 3 == 1), isWild = (i % 3 == 2);
    beginShape();
    for (int step = 0; step <= 60; step++) {
      float z = isTop ? map(step, 0, 60, 0, maxZ) : isBot ? map(step, 0, 60, 0, -maxZ) : map(step, 0, 60, -maxZ, maxZ); 
      float absZ = abs(z), r = map(absZ / (absZ + eps), 0, 1, eps, 350);
      if (isWild) r += map(noise(i * 0.1, step * 0.1, frameCount * 0.02), 0, 1, -80, 80);
      float tw = (maxZ / (r + 5.0)) * 2.5, cA = bA + tw + (frameCount * 0.03 * (300 / (r + 20)));
      if (isWild) cA -= (tw * 0.5); 
      if (isTop) stroke(50, 150, 255, 180); else if (isBot) stroke(200, 50, 255, 180); else stroke(lerpColor(color(255, 50, 0, 200), color(255, 255, 0, 200), map(r, eps, 350, 0, 1)));
      vertex(r * cos(cA), r * sin(cA), z);
    }
    endShape();
  }
  popMatrix();
}

void drawCenteredWhirlpoolScene() {
  pushMatrix(); translate(width/2, height/2, -400); rotateX(PI / 2.5); rotateZ(globalRotation);
  for(int i = 0; i < 40; i++) {
    float t = i / 39.0f, z = map(t, 0, 1, 200, -700), r = map(pow(t, 1.8), 0, 1, 400, 10);
    pushMatrix(); translate(0, 0, z); stroke(50, 150, 255, map(t, 0, 1, 255, 50)); strokeWeight(3); noFill(); ellipse(0, 0, r*2, r*2); popMatrix();
  }
  stroke(255); strokeWeight(5); ellipse(0, 0, 500, 500);
  
  // Universal Kinematic Addition: Central Angular Normal Vector
  float globalOmega = map(stirSpeed, 0.01, 0.15, 50, 300);
  drawArrow(0, 0, 0, 0, 0, globalOmega, color(0, 255, 100), 8);
  
  int vecs = round(vectorSlider.getValue());
  for(int i = 0; i < vecs; i++) {
    float a = i * TWO_PI / vecs;
    float mag = map(stirSpeed, 0.01, 0.15, 30, 250);
    drawArrow(250*cos(a), 250*sin(a), 0, -sin(a)*mag, cos(a)*mag, 0, color(255, 50, 50), 6); // Changed to Red
  }
  popMatrix();
}

void drawWanderingIntersectionScene() {
  pushMatrix(); translate(width/2, height/2, -400); rotateX(PI / 2.5);
  pushMatrix(); rotateZ(globalRotation);
  for(int i = 0; i < 30; i++) {
    float t = i / 29.0f, z = map(t, 0, 1, 200, -700), r = map(pow(t, 1.8), 0, 1, 400, 15);
    pushMatrix(); translate(0, 0, z); stroke(100, 100, 200, 100); strokeWeight(2); noFill(); ellipse(0, 0, r*2, r*2); popMatrix();
  }
  popMatrix();
  float wX = map(noise(frameCount * 0.01), 0, 1, -300, 300), wY = map(noise(frameCount * 0.01 + 1000), 0, 1, -300, 300);
  pushMatrix(); translate(wX, wY, 0); stroke(255, 200, 0, 200); strokeWeight(3); line(0, 0, -800, 0, 0, 400);
  fill(255, 200, 0, 50); stroke(255, 200, 0, 120); strokeWeight(1.5);
  for(int i = 0; i < 24; i++) {
    float t1 = i / 24.0f, t2 = (i + 1) / 24.0f;
    float z1 = map(t1, 0, 1, 300, -700), z2 = map(t2, 0, 1, 300, -700);
    float r1 = map(pow(t1, 1.5), 0, 1, 280, 0), r2 = map(pow(t2, 1.5), 0, 1, 280, 0);
    beginShape(TRIANGLE_STRIP);
    for(int j = 0; j <= 30; j++) {
      float a = (j * TWO_PI / 30.0f) + (currentStir * 2.0);
      vertex(r1*cos(a), r1*sin(a), z1); vertex(r2*cos(a), r2*sin(a), z2);
    }
    endShape();
  }
  if (isMultiSectionMode) {
    int secs = round(crossSectionSlider.getValue());
    for (int s = 0; s < secs; s++) drawStaticGreenRing(map(s / (float)max(1, secs - 1), 0, 1, 300, -700));
  } else {
    drawStaticGreenRing(map(sin(frameCount * 0.02), -1, 1, -200, 200));
  }
  popMatrix(); popMatrix();
}

void drawStaticGreenRing(float zHeight) {
  float t = map(zHeight, 300, -700, 0, 1), r = map(pow(t, 1.5), 0, 1, 280, 0); 
  pushMatrix(); translate(0, 0, zHeight); stroke(50, 255, 100); strokeWeight(6); noFill(); ellipse(0, 0, r*2, r*2);
  
  // Universal Kinematic Addition: Central Angular Normal Vector
  float globalOmega = map(stirSpeed, 0.01, 0.15, 50, 300);
  drawArrow(0, 0, 0, 0, 0, globalOmega, color(0, 255, 100), 8);
  
  int vecs = round(vectorSlider.getValue());
  for(int i = 0; i < vecs; i++) {
    float a = (i * TWO_PI / vecs) + currentStir * 3;
    float mag = map(stirSpeed, 0.01, 0.15, 40, 300);
    drawArrow(r*cos(a), r*sin(a), 0, -sin(a)*mag, cos(a)*mag, 0, color(255, 50, 50), 6);
  }
  popMatrix();
}

void drawTwinWhirlpoolsScene() {
  pushMatrix(); translate(width/2, height/2, -500); rotateX(PI / 2.5); rotateZ(globalRotation * 0.8);
  for (int w = -1; w <= 1; w += 2) {
    pushMatrix(); translate(w * 180, 0, 0);
    for(int i = 0; i < 25; i++) {
      float t = i / 24.0f, z = map(t, 0, 1, 150, -500), r = map(pow(t, 1.5), 0, 1, 220, 10);
      pushMatrix(); translate(0, 0, z); stroke(map(w, -1, 1, 50, 200), 100, map(w, -1, 1, 255, 150), map(t, 0, 1, 255, 50)); strokeWeight(3); noFill(); ellipse(0, 0, r*2, r*2); 
      
      // Universal Kinematic Addition to a prominent inner ring
      if (i == 4) {
        float globalOmega = map(stirSpeed, 0.01, 0.15, 50, 300);
        drawArrow(0, 0, 0, 0, 0, globalOmega, color(0, 255, 100), 8); // Central Normal Vector
        int vecs = round(vectorSlider.getValue());
        for(int v_idx = 0; v_idx < vecs; v_idx++) {
            float a = v_idx * TWO_PI / vecs + currentStir;
            float mag = map(stirSpeed, 0.01, 0.15, 20, 150);
            drawArrow(r*cos(a), r*sin(a), 0, -sin(a)*mag, cos(a)*mag, 0, color(255, 50, 50), 5); // Red Tangentials
        }
      }
      popMatrix();
    }
    popMatrix();
  }
  popMatrix();
}

void drawOceanVortexScene() {
  pushMatrix(); translate(width/2, height/2 + 100, -400); rotateX(PI / 2.7); rotateZ(globalRotation * 0.4);
  for(int i = 0; i < 60; i++) {
    float t = i / 59.0f, z = map(t, 0, 1, 100, -900), r = map(pow(t, 0.8), 0, 1, 800, 5);
    pushMatrix(); translate(0, 0, z); stroke(0, 80, 150, map(t, 0, 1, 200, 20)); strokeWeight(4); noFill(); ellipse(0, 0, r*2, r*2); 
    
    // Universal Kinematic Addition inside the deep ocean well
    if (i == 8) {
        float globalOmega = map(stirSpeed, 0.01, 0.15, 50, 300);
        drawArrow(0, 0, 0, 0, 0, globalOmega, color(0, 255, 100), 8); // Central Normal Vector
        int vecs = round(vectorSlider.getValue());
        for(int v_idx = 0; v_idx < vecs; v_idx++) {
            float a = v_idx * TWO_PI / vecs + currentStir;
            float mag = map(stirSpeed, 0.01, 0.15, 30, 250);
            drawArrow(r*cos(a), r*sin(a), 0, -sin(a)*mag, cos(a)*mag, 0, color(255, 50, 50), 6); // Red Tangentials
        }
    }
    popMatrix();
  }
  popMatrix();
}

// --------------------------------------------------------
// Precomputed High-Performance Distorted Funnel
// --------------------------------------------------------
void drawVariableRandomWhirlpoolScene() {
  pushMatrix(); translate(width/2, height/2 - 50, -450); rotateX(PI / 2.5);
  
  // Precompute vertex metrics to save thousands of math operations per frame
  int rings = 50;
  float[] cx = new float[rings]; float[] cy = new float[rings]; 
  float[] z = new float[rings]; float[] r = new float[rings];
  
  for(int i = 0; i < rings; i++) {
    float t = i / (float)(rings - 1);
    z[i] = map(t, 0, 1, 300, -800);
    cx[i] = (noise(t * 3.0f, frameCount * 0.01f + currentWhirlpoolSeed) - 0.5f) * 250f * (1.0f - t);
    cy[i] = (noise(t * 3.0f + 50f, frameCount * 0.01f + currentWhirlpoolSeed) - 0.5f) * 250f * (1.0f - t);
    r[i] = max(0, map(pow(t, 1.4f), 0, 1, 360, 0) + map(noise(t * 7.0f + currentWhirlpoolSeed * 2), 0, 1, -100, 100) * (1.0f - t));
  }

  for(int a = 0; a < 4; a++) {
    noFill(); stroke(255, 200, 0, 160); strokeWeight(3); beginShape();
    for(int s = 0; s <= 30; s++) {
      float t = s / 30.0f;
      vertex((noise(t*3f, frameCount*0.01f + a + currentWhirlpoolSeed)-0.5f)*250f*(1f-t), (noise(t*3f+50f, frameCount*0.01f + a + currentWhirlpoolSeed)-0.5f)*250f*(1f-t), map(t, 0, 1, 300, -800));
    }
    endShape();
  }

  pushMatrix(); rotateZ(globalRotation * 1.2); fill(255, 200, 0, 55); stroke(255, 200, 0, 130); strokeWeight(1.5);
  for(int i = 0; i < rings - 1; i++) {
    beginShape(TRIANGLE_STRIP);
    float t1 = i / (float)(rings - 1), t2 = (i + 1) / (float)(rings - 1);
    for(int j = 0; j <= 35; j++) {
      float theta1 = (j * TWO_PI / 35.0f) + (currentStir * 3.0) + (t1 * 8.0);
      float theta2 = (j * TWO_PI / 35.0f) + (currentStir * 3.0) + (t2 * 8.0);
      vertex(cx[i] + r[i] * cos(theta1), cy[i] + r[i] * sin(theta1), z[i]); 
      vertex(cx[i+1] + r[i+1] * cos(theta2), cy[i+1] + r[i+1] * sin(theta2), z[i+1]);
    }
    endShape();
  }
  
  if (isMultiSectionMode) {
    int secs = round(crossSectionSlider.getValue());
    for (int s = 0; s < secs; s++) drawDistortedGreenRing(map(s / (float)max(1, secs - 1), 0, 1, 0.05, 0.95));
  } else {
    drawDistortedGreenRing(map(sin(frameCount * 0.025), -1, 1, 0.05, 0.95));
  }
  popMatrix(); popMatrix();
}

void drawDistortedGreenRing(float tVal) {
  float radius = max(0, map(pow(tVal, 1.4f), 0, 1, 360, 0) + map(noise(tVal * 7.0f + currentWhirlpoolSeed * 2), 0, 1, -100, 100) * (1.0f - tVal));
  float cx = (noise(tVal * 3.0f, frameCount * 0.01f + currentWhirlpoolSeed) - 0.5f) * 250f * (1.0f - tVal);
  float cy = (noise(tVal * 3.0f + 50f, frameCount * 0.01f + currentWhirlpoolSeed) - 0.5f) * 250f * (1.0f - tVal);
  pushMatrix(); translate(cx, cy, map(tVal, 0, 1, 300, -800)); stroke(50, 255, 100); strokeWeight(6); noFill(); ellipse(0, 0, radius*2, radius*2);
  
  // Universal Kinematic Addition: Central Angular Normal Vector
  float globalOmega = map(stirSpeed, 0.01, 0.15, 50, 300);
  drawArrow(0, 0, 0, 0, 0, globalOmega, color(0, 255, 100), 8);
  
  int vecs = round(vectorSlider.getValue());
  for(int i = 0; i < vecs; i++) {
    float a = (i * TWO_PI / vecs) + (currentStir * 3.0) + (tVal * 8.0);
    float mag = map(stirSpeed, 0.01, 0.15, 40, 300);
    drawArrow(radius*cos(a), radius*sin(a), 0, -sin(a)*mag, cos(a)*mag, 0, color(255, 50, 50), 6);
  }
  popMatrix();
}

// --------------------------------------------------------
// HUD System
// --------------------------------------------------------
void drawHUD(String title, String subtitle) {
  hint(DISABLE_DEPTH_TEST); 
  fill(0, 180); noStroke(); rect(0, 0, width, height * 0.16);
  fill(255); textSize(displayDensity * 16); textAlign(LEFT, CENTER); text(title, 40, height * 0.06);
  fill(200, 255, 200); textSize(displayDensity * 13); text(subtitle, 40, height * 0.11);
  textAlign(CENTER, CENTER); hint(ENABLE_DEPTH_TEST); 
}

// ========================================================
// GLOBAL UI CLASSES
// ========================================================
class SimpleButton {
  float x, y, w, h; String label; boolean pressed = false;
  SimpleButton(float x, float y, float w, float h, String label) { this.x = x; this.y = y; this.w = w; this.h = h; this.label = label; }
  void display() {
    hint(DISABLE_DEPTH_TEST);
    fill(pressed ? color(100, 150, 255) : color(30, 60, 100)); stroke(150, 200, 255); strokeWeight(2); rect(x, y, w, h, 15);
    fill(255); textSize(displayDensity * 14); textAlign(CENTER, CENTER); text(label, x + w/2, y + h/2 - 2);
    hint(ENABLE_DEPTH_TEST);
  }
  void checkPress(float mx, float my) { if (mx > x && mx < x + w && my > y && my < y + h) pressed = true; }
  boolean checkRelease(float mx, float my) {
    if (pressed) { pressed = false; if (mx > x && mx < x + w && my > y && my < y + h) return true; }
    return false;
  }
}

class CustomSlider {
  float x, y, w, h, minVal, maxVal, currentVal; String label; boolean isStep, isVisible = false, isDragging = false;
  CustomSlider(float x, float y, float w, float h, float minVal, float maxVal, float defaultVal, String label, boolean isStep) {
    this.x = x; this.y = y; this.w = w; this.h = h; this.minVal = minVal; this.maxVal = maxVal; this.currentVal = defaultVal; this.label = label; this.isStep = isStep; 
  }
  void display() {
    if (!isVisible) return;
    hint(DISABLE_DEPTH_TEST);
    fill(30, 40, 50, 220); stroke(100, 200, 255, 120); strokeWeight(2); rect(x, y, w, h, 25);
    float handleX = map(currentVal, minVal, maxVal, x, x + w);
    fill(50, 150, 255, 180); noStroke(); rect(x, y, handleX - x, h, 25, 0, 0, 25);
    fill(255); stroke(200); strokeWeight(1); ellipse(handleX, y + h/2, h + 10, h + 10);
    fill(255); textSize(displayDensity * 14); textAlign(CENTER, BOTTOM); text(label + " : " + (isStep ? str(round(currentVal)) : nf(currentVal, 0, 3)), x + w/2, y - 10);
    textAlign(CENTER, CENTER); hint(ENABLE_DEPTH_TEST);
  }
  void checkPress(float mx, float my) { if (isVisible && mx > x - 30 && mx < x + w + 30 && my > y - 30 && my < y + h + 30) { isDragging = true; updateValue(mx); } }
  void checkDrag(float mx) { if (isDragging) updateValue(mx); }
  void checkRelease() { isDragging = false; }
  void updateValue(float mx) { currentVal = map(constrain(mx, x, x + w), x, x + w, minVal, maxVal); if (isStep) currentVal = round(currentVal); }
  float getValue() { return currentVal; }
  void show() { isVisible = true; }
  void hide() { isVisible = false; isDragging = false; }
}
