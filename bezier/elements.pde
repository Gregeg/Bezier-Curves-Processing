void drawBot(Vector2D pos, double rot) {
  pushMatrix();
  translate((float)pos.x, (float)pos.y);
  rotate((float)rot);
  stroke(255, 0, 0, 50);
  fill(255, 0, 0, 50);
  image(botrot, -botrot.width/2*botRotScale, -botrot.height/2*botRotScale, botrot.width*botRotScale, botrot.height*botRotScale);
  if(skidding && simulation)
    rect(-botrot.width/2*botRotScale, -botrot.height/2*botRotScale, botrot.width*botRotScale, botrot.height*botRotScale);
  popMatrix();
  stroke(0, 0, 0);
}
