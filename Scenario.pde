class Scenario{
  private String name;
  private String sample_file;
  private float currSpeed;
  private float[] currDist;
  private float currRotation;
  private String historyFile;
  
  public Scenario(String historyFile, String name, float[] currDist) {
    this(historyFile, name, 0.0, currDist, 0.0);
  }
  
  public Scenario(String historyFile, String name, float currSpeed, float[] currDist, float currRotation) {
    this.name = name;
    this.currSpeed = currSpeed;
    this.currDist = currDist;
    this.currRotation = currRotation;
    this.historyFile = historyFile;
  }
  
  public Scenario(Scenario scenario) {
    this.historyFile = scenario.historyFile;
    this.name = scenario.name;
    this.currSpeed = scenario.currSpeed;
    this.currDist = scenario.currDist;
    this.currRotation = scenario.currRotation;
  }
  
  public String getName() {
    return name;
  }
  
  public String getHistoryFile() {
    return historyFile;
  }
  
  public void setCurrSpeed(float val) {
    currSpeed = val;
  }
  public void setCurrDist(float[] val) {
    currDist = val;
  }
  public void setCurrRotation(float val) {
    currRotation = val;
  }
  
  public float getCurrSpeed() {
    return currSpeed;
  }
  public float[] getCurrDist() {
    return currDist;
  }
  public float getCurrRotation() {
    return currRotation;
  }
  
  public String toString() {
    return name + 
      "\nCurrSpeed: " + currSpeed + "\nCurrDist: " + currDist + "\nCurrRotation: " + currRotation;
  }
  
  public boolean equals(Scenario other) {
    if (this.name.equals(other.name)) {
      return true;
    }
    return false;
  }
}
