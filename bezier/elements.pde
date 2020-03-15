void drawBot(Vector2D pos, double rot) {
  pushMatrix();
  translate((float)pos.x, (float)pos.y);
  rotate((float)rot);
  image(botrot, -botrot.width/2, -botrot.height/2);
  popMatrix();
}
