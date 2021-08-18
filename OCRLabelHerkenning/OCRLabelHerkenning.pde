import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.ZonedDateTime;

String imageFolder = "IMAGE_FOLDER";
HashMap<String, Scan> scans = new HashMap();
int index=0;
String imageNames[]; //all imageNames
PImage img;

void setup() {
  size(1750, 600, P2D);

  imageNames = loadStrings("private/all-imageNames.txt");
  for (String name : imageNames) {
    scans.put(name, new Scan(name));
  }

  //load textlines and add to scans
  //and try to find label(s)
  Table table = loadTable("private/page1-1500.csv", "header");
  for (TableRow row : table.rows()) { //contains only scans with at least one textline
    TextLine t = new TextLine(row);
    Scan scan = scans.get(t.image);
    scan.image = t.image;
    scan.imageID = t.imageID;
    scan.textlines.add(t);

    if (t.text.indexOf("datum:")>-1 && abs(t.x-2300)<500) scan.addLabel("bdate", t.x, t.y, t.text);
    if (t.text.indexOf("plaats:")>-1) scan.addLabel("bplace", t.x, t.y, t.text);
    if (t.text.indexOf("aam:")>-1) scan.addLabel("naam", t.x, t.y, t.text);
    if (t.text.indexOf("dres:")>-1) scan.addLabel("adres", t.x, t.y, t.text);
    if (t.text.indexOf("beroep:")>-1) scan.addLabel("beroep", t.x, t.y, t.text);
    if (t.text.indexOf("unctie:")>-1) scan.addLabel("functie", t.x, t.y, t.text);
    if (t.text.indexOf("ongehuwd:")>-1) scan.addLabel("gehuwd", t.x, t.y, t.text);
  }

  //find values for labels
  for (Scan scan : scans.values()) {
    for (Label label : scan.labels.values()) {
      for (TextLine t : scan.textlines) {

        if (t.x>label.x && t.y>label.y-50 && t.y<label.y+50) {
          if (label.id.equals("naam") && (abs(t.x-t.imageWidth)<550)) {
            continue; //skip text in upper-right corner
          }
          label.value += " " + t.text;
        }
      }
    }
  }

  //cleanup label values
  for (Scan scan : scans.values()) {
    for (Label label : scan.labels.values()) {
      String s = label.value;
      s = s.replaceAll("Geb.datum:", "");
      s = s.replaceAll("Geb. datum:", "");
      s = s.replaceAll("geb- ", "");
      s = s.replaceAll("ieb- ", "");
      s = s.replaceAll("Jeb- ", "");
      s = s.replaceAll("eb- ", "");
      s = s.replaceAll("datum:", "");
      s = s.replaceAll("Geb.plaats:", "");
      s = s.replaceAll("Geb. plaats:", "");
      s = s.replaceAll("plaats:", "");
      s = s.replaceAll("Functie:", "");
      s = s.replaceAll("Burgerl. beroep:", "");
      s = s.replaceAll("burgerl.", "");
      s = s.replaceAll("urgerl.", "");
      s = s.replaceAll("irgerl.", "");
      s = s.replaceAll("rgerl.", "");
      s = s.replaceAll("gerl.", "");
      s = s.replaceAll("beroep:", "");
      s = s.replaceAll("Adres:", "");
      s = s.replaceAll("Gehuwd of ongehuwd:", "");
      s = s.replaceAll("ehuwd of ongehuwd:", "");
      s = s.replaceAll("of ongehuwd:", "");
      s = s.replaceAll("f ongehuwd:", "");
      s = s.replaceAll("Naam:", "");
      s = s.replaceAll("aam:", "");

      label.value = trim(s);
    }
  }

  //fix date
  for (Scan scan : scans.values()) {
    Label bdate = scan.labels.get("bdate");
    if (bdate!=null) {
      bdate.value = bdate.value.replaceAll("\\.","-");
      DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d-M-yyyy");
      try {
        LocalDate date = LocalDate.parse(bdate.value, formatter);
        if (date.isAfter(LocalDate.parse("1931-01-01"))) { //date is too recent. make invalid
          bdate.value = "x " + bdate.value;
        } else {
          bdate.value = date.toString();
        }
        //println(date);
      }
      catch (Exception e) {
        println("warning cannot parse date",bdate); // \""+bdate.value+"\"");
        bdate.value = "x " + bdate.value;
      }
    }
  }

  //prepare result table
  table = new Table();
  table.addColumn("image");
  table.addColumn("preview");
  table.addColumn("naam");
  table.addColumn("bdate");
  table.addColumn("bplace");
  table.addColumn("adres");
  table.addColumn("functie");
  table.addColumn("beroep");
  table.addColumn("gehuwd");

  //fill table
  for (String name : imageNames) {
    Scan scan = scans.get(name);
    TableRow row = table.addRow();
    row.setString("image", scan.image);
    if (scan.imageID!=null) row.setString("preview", "https://files.transkribus.eu/iiif/2/"+scan.imageID+"/full/,500/0/default.jpg");
    for (Label label : scan.labels.values()) {
      row.setString(label.id, label.value);
    }
  }
  saveTable(table, "private/result.csv");

  exit();
}

void draw() {
}
