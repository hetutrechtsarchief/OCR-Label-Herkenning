import java.awt.Rectangle;

class TextLine extends Rectangle {
  String image,id,text,imageID;
  int right,bottom,imageWidth,imageHeight;
  
  TextLine(TableRow row) {
    this.image = row.getString("image");
    this.imageWidth = row.getInt("imageWidth");
    this.imageHeight = row.getInt("imageHeight");
    this.imageID = row.getString("imageID");
    this.id = row.getString("id");
    this.text = row.getString("text");
    this.x = row.getInt("x");
    this.y = row.getInt("y");
    this.width = row.getInt("width");
    this.height = row.getInt("height");
    this.right = this.imageWidth-this.x;
    this.bottom = this.imageHeight-this.y;
  }
}
