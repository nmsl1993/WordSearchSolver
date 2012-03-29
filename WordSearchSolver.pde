import java.lang.ProcessBuilder;
import javax.swing.*;
import javax.swing.SwingUtilities;
import javax.swing.filechooser.*;
import java.util.HashSet;
import java.util.Random;

Random rand = new Random();
//HashSet<String> wordsearch_data = new HashSet<String>();
HashSet<String> dictionary = new HashSet<String>();
ArrayList<Word> words = new ArrayList<Word>();

char[][] wordsearch_data;
int text_width = 30;
int text_height = 30;
int offset = 15;
int vertical_kludge = 4;
color cr=color(255, 0, 0);      //defines RED
color cg=color(0, 255, 0);      //defines GREEN
color cb=color(0, 0, 255);      //defines BLUE
color cy=color(175, 154, 13);    //defines YELLOW
int stroke_transparency = 68;
int cur_word_index = 0;
final boolean DEBUG = false;
color[] colors = {            //random selects one of above colors
  cb, cr, cg, cy
};

void setup()
{ 
  if (DEBUG)
  {
    frameRate(3);
  }
  smooth();
  strokeWeight(3);
  String image_path;
  File temp = null;
  JFileChooser fc = new JFileChooser(sketchPath(""));
  if (fc.showOpenDialog(this) != JFileChooser.APPROVE_OPTION)
  {
    System.exit(1);
    //return;
    //exit();
  }
  else
  {
    try
    {
      image_path = fc.getSelectedFile().getCanonicalPath();
      temp = File.createTempFile("wordsearch", "temp", new File(dataPath("")));
      temp.deleteOnExit();
      //String arg = "tesseract " + image_path + " " + dataPath("") + "test.txt" + " -psm 6";
      String arg = "tesseract " + image_path + " " + temp.getCanonicalPath() + " -psm 6";

      println(arg);
      Process proc = Runtime.getRuntime().exec(arg);
      InputStream in = proc.getInputStream();
      int c;
      while ( (c = in.read ()) != -1) {
        print((char)c);
      }
      in.close();
      //proc.waitFor();
      File dest = new File(temp.getCanonicalPath() + ".txt");
      dest.deleteOnExit();
      BufferedReader bir = new BufferedReader(new FileReader(dest));
      String input = bir.readLine();
      ArrayList<String> ocr_results = new ArrayList<String>();
      while (input != null)
      {
        if (!input.matches("\\s*"))
        {
          ocr_results.add(input);
        }
        input = bir.readLine();
      }
      bir.close();
      println("size " + ocr_results.size());
      wordsearch_data = new char[ocr_results.size()][];
      for (int d = 0; d < ocr_results.size(); d++)
      {
        wordsearch_data[d] = ocr_results.get(d).replaceAll(" ", "").toCharArray();
        println(wordsearch_data[d].length);
      }
      //size(100+ wordsearch_data[0].length*text_width, 100 + wordsearch_data.length*text_height);
      size(wordsearch_data[0].length*text_width, wordsearch_data.length*text_height);
      String dictionary_path = dataPath("/Dictionaries/2of12.txt");

      BufferedReader dictRead = new BufferedReader(new FileReader(dictionary_path));
      String tempInput = dictRead.readLine();
      while (tempInput != null)
      {
        if (tempInput.length() > 1)
        {
          dictionary.add(tempInput.toLowerCase());
        }
        tempInput = dictRead.readLine();
      }
      dictRead.close();

      /*
      dictionary.clear();
       dictionary.add("TGE".toLowerCase());
       dictionary.add("DJE".toLowerCase());
       */
    }
    catch(Exception e)
    {
      e.printStackTrace();
    }
  }
  populateWords();
}
void populateWords()
{
  words.addAll(checkDiagonal());
  words.addAll(checkVertical());
  words.addAll(checkHorizontal());
}
void drawLetters()
{
  fill(0);
  textSize(text_width);
  textAlign(CENTER);
  ellipseMode(CENTER);
  for (int y = 0; y < wordsearch_data.length; y++)
  {
    for (int x = 0; x < wordsearch_data[y].length; x++)
    {
      if (DEBUG)
      {
        ellipse(offset + (x*text_height), offset + (y*text_height), 5, 5);
      }
      if (DEBUG)
      {
        println(wordsearch_data[y][x] + " at " + x + " " + y);
      }
      pushMatrix();

      translate(0, text_height/2);
      text(wordsearch_data[y][x], offset + (x*text_height), offset + (y*text_height));
      popMatrix();
    }
  }
  if (!DEBUG)
  {
    drawWords();
  }
  //noLoop();
}
void draw()
{
  background(255);
  drawLetters();

  if (DEBUG)
  {
    slowDraw();
  }
  if (!DEBUG)
  {
    drawWords();
    noLoop();
  }
}


void drawWords()
{
  noFill();
  for (Word w : words)
  {
    drawWord(w);
  }
}
void slowDraw()
{
  if (cur_word_index >= words.size())
  {
    noLoop();
  }
  else
  {
    drawWord(words.get(cur_word_index));
  }

  cur_word_index++;
}
void drawWord(Word w)
{
  stroke((colors[rand.nextInt(4)]), stroke_transparency);
  //stroke(cb, stroke_transparency);
  //line(offset + (x*text_height), offset + (start*text_height) - text_width/2, offset + (x*text_height), offset + (end*text_height) - text_width/2);
  float ymedian = (offset + (w.starty*text_height) + offset + (w.endy*text_height))/2 + vertical_kludge;
  float xmedian = (offset + (w.startx*text_height) + offset + (w.endx*text_height))/2;

  float wt = (offset + ((w.endx + 1)*text_width) - text_height/2) - (offset + (w.startx*text_width) - text_height/2);

  float ht = (offset + ((w.endy + 1)*text_height) - text_width/2) - (offset + (w.starty*text_height) - text_width/2);
  if (DEBUG)
  {
    println("width " + wt + " height " + ht);
    println("xmedian " + xmedian + " ymedian " + ymedian);
  }
  if (wt > text_width && ht > text_width)
  { 
    pushMatrix();
    println(w.contents);
    translate(xmedian, ymedian);
    rotate(-atan(wt/ht));
    float hypotenuse_length = sqrt(sq(wt) + sq(ht));
    stroke((colors[rand.nextInt(4)]), stroke_transparency);
    ellipse(0, 0, text_width, hypotenuse_length);
    popMatrix();
  }
  else
  {
    ellipse(xmedian, ymedian, wt, ht);
  }
}
void mousePressed()
{
  println(mouseX + " " + mouseY);
}
HashSet<Word> checkVertical()
{
  noFill();
  println("start");
  HashSet<Word> verticalWords = new HashSet<Word>();
  for (int x = 0; x < wordsearch_data[0].length; x++)
  {
    if (DEBUG)
    {
      println("x increment");
    }
    HashSet<Word> temp = new HashSet<Word>();

    for (int start = 0; start < wordsearch_data.length; start++)
    {
      for (int end = start + 1; end < wordsearch_data.length; end++)
      {
        String canidate = "";
        for (int ind = start; ind <= end; ind++)
        {
          //println("x " + x + " y " + ind);
          canidate += wordsearch_data[ind][x];
        }
        if (dictionary.contains(canidate.toLowerCase()))
        {
          temp.add(new Word(canidate, x, start, x, end));
          if (DEBUG)
          {
            println(canidate);
          }
        }
      }
      verticalWords.addAll(eliminateInsideWords(temp));
    }
  }
  println("done");
  return verticalWords;
}
HashSet<Word> checkHorizontal()
{
  noFill();
  println("start Horizontal");
  HashSet<Word> horizontalWords = new HashSet<Word>();
  for (int y = 0; y < wordsearch_data.length - 1; y++)
  {
    if (DEBUG)
    {
      println("y increment");
    }
    HashSet<Word> temp = new HashSet<Word>();
    for (int start = 0; start < wordsearch_data[0].length; start++)
    {
      for (int end = start + 1; end < wordsearch_data[0].length; end++)
      {
        String canidate = "";
        for (int ind = start; ind <= end; ind++)
        {
          //println("x " + ind + " y " + y);
          canidate += wordsearch_data[y][ind];
        }
        if (dictionary.contains(canidate.toLowerCase()))
        {
          temp.add(new Word(canidate, start, y, end, y));
        }
      }
      horizontalWords.addAll(eliminateInsideWords(temp));
    }
  }
  println("done");
  return horizontalWords;
}
HashSet<Word> checkDiagonal()
{
  HashSet<Word> diagonalWords = new HashSet<Word>();
  for (int x = 0; x < wordsearch_data[0].length; x++)
  {
    HashSet<Word> temp = new HashSet<Word>();
    for (int start = 0; start < wordsearch_data.length; start++)
    {
      try
      {
        for (int end = start + 1; end < wordsearch_data.length; end++)
        {
          String canidate = "";
          for (int ind = start; ind <= end; ind++)
          {

            canidate += wordsearch_data[ind][ind + x];
          }
          if (dictionary.contains(canidate.toLowerCase()))
          {
            temp.add(new Word(canidate, start + x, start, end + x, end));
          }
        }
      }
      catch(ArrayIndexOutOfBoundsException e)
      {
        if (DEBUG)
        {
          println("aop");
        }
      }
    }
    diagonalWords.addAll(eliminateInsideWords(temp));
  }
  for (int y = 1; y < wordsearch_data.length; y++)
  {
    HashSet<Word> temp = new HashSet<Word>();
    for (int start = 0; start < wordsearch_data[0].length; start++)
    {
      try
      {
        for (int end = start + 1; end < wordsearch_data[0].length; end++)
        {
          String canidate = "";
          for (int ind = start; ind <= end; ind++)
          {

            canidate += wordsearch_data[ind + y][ind];
          }
          if (dictionary.contains(canidate.toLowerCase()))
          {
            temp.add(new Word(canidate, start, start + y, end, end + y));
          }
        }
      }
      catch(ArrayIndexOutOfBoundsException e)
      {
        if (DEBUG)
        {
          println("aop");
        }
      }
    }
    diagonalWords.addAll(eliminateInsideWords(temp));
  }
  return diagonalWords;
}
HashSet<Word> eliminateInsideWords(HashSet<Word> temp)
{

  HashSet<Word> copied = new HashSet<Word>(temp);
  for (Word w : copied)
  {
    for (Word r : copied)
    {
      if (w.contents.contains(r.contents) && ! w.contents.equals(r.contents))
      {
        temp.remove(r);
      }
    }
  }

  return temp;
}

