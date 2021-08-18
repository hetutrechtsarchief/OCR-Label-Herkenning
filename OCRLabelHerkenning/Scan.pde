class Scan {
  String image, imageID;
  ArrayList<TextLine> textlines = new ArrayList();
  HashMap<String, Label> labels = new HashMap();

  Scan(String imgName) {
    this.image = imgName;
  }

  void addLabel(String id, int x, int y, String text) {
    labels.put(id, new Label(id, x, y, text));
  }

  PVector getLabel(String id) {
    return labels.get(id);
  }
}

class Label extends PVector {
  String id, value;

  Label(String id, int x, int y, String text) {
    this.x = x;
    this.y = y;
    this.id = id;
    this.value = text;
  }
  
  String toString() {
    return "x="+int(x)+" y="+int(y)+" id="+id+" value="+value;
  }
}
