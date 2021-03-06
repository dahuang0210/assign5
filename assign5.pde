/** 
 Assignment 5
 Author:          Bao Yuchen
 Student Number:  103254021
 Update:          2015/12/03
 */

public class ObjType {
  final static int FIGHTER = 1, ENEMY = 2, TREASURE = 3, BULLET = 4;
  final static int BACKGROUND = 10, TITLE = 11;
  final static int NOTHING = -1, UNKNOWN = 0;
}

final int MOUSE_LEFT = 37, MOUSE_RIGHT = 39, MOUSE_MID = 3;

ResourcesManager resourcesManager = null;

private GamePlayScene gameMain = null;

/**
 * to initialize system
 */
void setup () {
  size(640, 480) ;
  resourcesManager = new ResourcesManager();
  gameMain = new GamePlayScene();
}


void draw() {
  gameMain.drawFrame();
}

//-------------------------- override listener method --------------------------

void mouseMoved() {
  gameMain.mouseMovedFun(mouseX, mouseY);
}

void mousePressed() {
  gameMain.mousePressedFun(mouseButton);
}

void mouseReleased() {
  gameMain.mouseReleasedFun(mouseButton);
}

/**
 * when key pressed
 */
void keyPressed() {
  gameMain.keyPressedFun(keyCode);
}

/**
 * when key released
 */
void keyReleased() {
  gameMain.keyReleasedFun(keyCode);
}

//****************************************************************************************************************
//****************************************************************************************************************

//================================================================================================================
//================================================================================================================

interface MouseListener {
  public void mouseReleasedFun(int keyCode1) ;
  public void mousePressedFun(int keyCode1) ;
  public void mouseMovedFun(int x, int y);
}

//================================================================================================================
//================================================================================================================

interface KeyPressListener {
  public void keyReleasedFun(int keyCode1) ;
  public void keyPressedFun(int keyCode1) ;
}

//================================================================================================================
//================================================================================================================

interface ScreenChangeListener {
  public void startGame() ;
  public void endGame(int level) ;
  public void restartGame() ;
}

//================================================================================================================
//================================================================================================================

interface GameDataChanged {
  public void addHP(int val);
  public void subHP(int val, DrawingOBJ obj);
  public void enemyMoveOut(Enemy target, boolean isShowFrameAnimation);
  public void FrameAnimationFinished(FrameAnimation target);
}

//****************************************************************************************************************
//****************************************************************************************************************

//================================================================================================================
//================================================================================================================

class ResourcesManager extends HashMap<Integer, PImage> {

  public final static int hp = 1;
  public final static int end1 = 10, end2 = 11;
  public final static int bg1 = 20, bg2 = 21;
  public final static int st1 = 30, st2 = 31;
  public final static int enemy = 40, enemy1=41;
  public final static int fighter = 50, treasure = 51, bullet = 52;
  public final static int explode = 70;

  public ResourcesManager() {
    super();
    loadResources();
  }


  private void addImage(int Key, String resName) {
    if (!this.containsKey(Key)) {
      PImage newRes = loadImage(resName);
      this.put(Key, newRes);
    }
  }
  /**
   * to load pictures
   */
  private void loadResources() {
    addImage(ResourcesManager.hp, "img/hp.png");
    addImage(ResourcesManager.end1, "img/end1.png");
    addImage(ResourcesManager.end2, "img/end2.png");
    addImage(ResourcesManager.bg1, "img/bg1.png");
    addImage(ResourcesManager.bg2, "img/bg2.png");
    addImage(ResourcesManager.st1, "img/start1.png");
    addImage(ResourcesManager.st2, "img/start2.png");
    addImage(ResourcesManager.enemy, "img/enemy.png");
    //addImage(ResourcesManager.enemy1, "img/Moocs-element-enemy1.png");
    addImage(ResourcesManager.fighter, "img/fighter.png");
    addImage(ResourcesManager.treasure, "img/treasure.png");
    addImage(ResourcesManager.bullet, "img/shoot.png");
    for (int i=0; i<5; i++) {
      addImage(ResourcesManager.explode+i, "img/flame"+(i+1)+".png");
    }
  }
}

//================================================================================================================
//================================================================================================================

class GamePlayScene implements ScreenChangeListener {

  Screen screenOBJ = null;
  KeyPressListener keyListener = null;
  MouseListener mouseListener = null;

  public GamePlayScene() {
    restartGame();
  }

  public void drawFrame() {
    if (screenOBJ != null) {
      screenOBJ.drawFrame();
    }
  }

  public void mouseMovedFun(int x, int y) {
    if (mouseListener != null) {
      mouseListener.mouseMovedFun(x, y);
    }
  }

  public void mousePressedFun(int code) {
    if (mouseListener != null) {
      mouseListener.mousePressedFun(code);
    }
  }

  public void mouseReleasedFun(int code) {
    if (mouseListener != null) {
      mouseListener.mouseReleasedFun(code);
    }
  }

  /**
   * when key pressed
   */
  public void keyPressedFun(int code) {
    if  (keyListener != null ) {
      keyListener.keyPressedFun(code);
    }
  }

  /**
   * when key released
   */
  public void keyReleasedFun(int code) {
    if  (keyListener != null ) {
      keyListener.keyReleasedFun(code);
    }
  }

  //--------------------------- handled by listener ---------------------------

  public void endGame(int level) {
    onScreenChange();
    GameEnd newScreen = new GameEnd(this);
    newScreen.level = level;
    screenOBJ = newScreen;
    mouseListener = newScreen;
  }

  public void startGame() {
    onScreenChange();
    OnGaming newScreen = new OnGaming(this);
    screenOBJ = newScreen;
    keyListener = newScreen;
  }

  public void restartGame() {
    onScreenChange();
    GameStart newScreen = new GameStart(this);
    screenOBJ = newScreen;
    mouseListener = newScreen;
  }

  //--------------------------- private method ---------------------------

  private void onScreenChange() {
    screenOBJ = null;
    keyListener = null;
    mouseListener = null;
  }
}

//================================================================================================================
//================================================================================================================

abstract class DrawingOBJ {
  public int classID = ObjType.NOTHING;
  public int objWidth, objHeight;
  public float x, y;
  public float xSpeed, ySpeed;
  public int zOrder;
  public int light, opacity;
  public float angle;
  protected PImage img = null;
  protected boolean isDrawSelf = true;

  public DrawingOBJ(int objWidth, int objHeight, PImage image, int classID) {
    this.objWidth = objWidth;
    this.objHeight = objHeight;
    this.classID = classID;
    img = image;
    x = 0;
    y = 0;
    xSpeed = 0;
    ySpeed = 0;
    light = 255;
    opacity = 255;
    zOrder = 0;
  }

  public void setIsDrawSelf(boolean isDrawSelf) {
    this.isDrawSelf = isDrawSelf;
  }

  public void updateAngle() {
    if (xSpeed == 0) {
      if (ySpeed>0) {
        angle = PI/2;
      } else {
        angle = -PI/2;
      }
    } else if (ySpeed == 0) {
      angle = 0;
    } else {
      angle = atan(ySpeed/xSpeed);
    }
  }

  public void updateLocation() {
    x += xSpeed;
    y += ySpeed;
  }

  public void drawFrame() {
    updateLocation();
    doGameLogic();
    SpecialDraw();
    if (isDrawSelf && (img != null)) {
      if ((light<255)||(opacity <255)) {
        tint(light, opacity);
      }
      int half_height = objHeight>>1;
      int half_width = objWidth>>1;
      if (angle!=0) {
        pushMatrix();
        translate(x, y);
        rotate(angle);
        image(img, -half_width, -half_height);
        popMatrix();
      } else {
        image(img, x-half_width, y-half_height);
      }
      if ((light<255)||(opacity <255)) {
        tint(255, 255);
      }
    }
  }

  boolean isPointHitArea(int px, int py, int x, int y, int r, int b) {
    return ((px > x) && (px < r) && (py > y) && (py < b));
  }

  public boolean isHitOBJ(DrawingOBJ obj) {
    return isHitOBJ(obj, 0, 0);
  }

  public boolean isHitOBJ(DrawingOBJ obj, int xxOffset, int yyOffset) {
    return isHit(floor(obj.x), floor(obj.y), obj.objWidth, obj.objHeight, floor(x), floor(y), objWidth-xxOffset, objHeight-yyOffset);
  }

  public boolean isHit(int ax, int ay, int aw, int ah, int bx, int by, int bw, int bh) {
    int xOffset = (bw >> 1), yOffset = (bh >> 1);
    int xOffset1 = aw >> 1, yOffset1 = ah >>1;
    int left = bx - xOffset, right = bx + xOffset;
    int top = by + yOffset, bottom = by - yOffset;
    int tl = ax - xOffset1, tr = ax + xOffset1;
    int tt = ay + yOffset1, tb = ay - yOffset1;
    if ((left< tr) && (right > tl)) {
      if ((bottom < tt)&&(top > tb)) {
        return true;
      }
    }
    return false;
  }

  public void drawStrokeText(String str, color textColor, color strokeColor, int textx, int texty, int strokeWidth) {
    fill(strokeColor);
    text(str, textx-strokeWidth, texty);
    text(str, textx+strokeWidth, texty);
    text(str, textx, texty-strokeWidth);
    text(str, textx, texty+strokeWidth);
    text(str, textx-strokeWidth, texty-strokeWidth);
    text(str, textx-strokeWidth, texty+strokeWidth);
    text(str, textx+strokeWidth, texty-strokeWidth);
    text(str, textx+strokeWidth, texty+strokeWidth);
    fill(textColor);
    text(str, textx, texty);
  }

  public void addYSpeed(float addValue) {
    float maxSpeed = getSpeed();
    ySpeed += addValue;
    if (ySpeed > maxSpeed ) {
      ySpeed = maxSpeed;
      xSpeed = 0;
    } else if (ySpeed < - maxSpeed) {
      ySpeed = - maxSpeed;
      xSpeed=0;
    } else if (ySpeed == 0) {
      xSpeed = maxSpeed;
    } else {
      xSpeed = sqrt(maxSpeed*maxSpeed-ySpeed*ySpeed);
    }
  }

  public void moveToOBJ(DrawingOBJ target) {
    moveToOBJ(target, 0.3);
  }

  public void moveToOBJ(DrawingOBJ target, float yAccelerated) {
    float yMove = (target.y - y);
    float xMove = (target.x - x);
    float targetYSpeed = 0;
    if (xMove!=0) {
      targetYSpeed = yMove / xMove * (xSpeed + target.xSpeed);
    }
    float speedErr = targetYSpeed - ySpeed;
    if (speedErr > yAccelerated) {
      addYSpeed(yAccelerated);
    } else if (speedErr < -yAccelerated) {
      addYSpeed(-yAccelerated);
    } else { 
      addYSpeed(speedErr);
    }
    updateAngle();
  }

  public float getSpeed() {
    if (xSpeed ==0 ) {
      return ceil(abs(ySpeed));
    } else if (ySpeed ==0) {
      return ceil(abs(xSpeed));
    } else {
      return sqrt(xSpeed*xSpeed +ySpeed*ySpeed);
    }
  }

  public float getDestanceBetweenOBJ(DrawingOBJ target) {
    return getDestanceBetweenOBJ(target.x, target.y);
  }

  public float getDestanceBetweenOBJ(float targetX, float targetY) {
    float xerr = targetX - x, yerr = targetY - y;
    return sqrt(xerr * xerr + yerr * yerr);
  }

  abstract public void SpecialDraw();
  abstract public void doGameLogic();
}

//================================================================================================================
//================================================================================================================

abstract class Screen extends DrawingOBJ {
  protected ScreenChangeListener listener;
  public Screen(PImage background, ScreenChangeListener listener) {
    super(0, 0, background, ObjType.BACKGROUND);
    this.listener = listener;
  }
}

//================================================================================================================
//================================================================================================================

class Fighter extends DrawingOBJ implements KeyPressListener {

  public int hp;
  public boolean healing;

  private ArrayList<Integer> xKeyStack, yKeyStack;                    // sequence of key pressed
  private int xKeyPressedTime=1, yKeyPressedTime=1;                   // how long did user pressed a key

  private color hpColor = #ffffff;
  private int healRange;
  public Fighter() {
    super(50, 50, resourcesManager.get(ResourcesManager.fighter), ObjType.FIGHTER);
    xKeyStack = new ArrayList();
    yKeyStack = new ArrayList();
    x = 600;
    y = 240;
    healing = false;
    healRange = 0;
  }

  public void setHP(int hp) {
    if (this.hp < hp) {
      healing = true;
    }
    this.hp = hp;
  }

  public void SpecialDraw() {
    float hpVal = hp;
    stroke(hpColor);
    fill(hpColor);
    ellipse(x, y, 45 + floor(hpVal/4f), 50);
    if (healing) {
      healRange +=10;
      ellipse(x, y, healRange, healRange);
      if (healRange >= 90) {
        healing = false;
      }
    } else if (healRange > 30) {
      healRange -= 5;
      ellipse(x, y, healRange, healRange);
    }
  }

  public void doGameLogic() {
    refreshKeyState();
    float hpVal = hp;
    if (hp>66) {
      int val = floor((hpVal - 66f) / 33f * 255f);
      hpColor = color(val, 255, val);
    } else if (hp>33) {
      int val = 255 - floor((hpVal - 33f) / 33f * 255f);
      hpColor = color(val, 255, 0);
    } else {
      int val = floor(hpVal / 33f * 255f);
      hpColor = color(255, val, 0);
    }
  }

  private void refreshKeyState() {
    if (xKeyStack.size()>0) {
      xKeyPressedTime ++;
      if (xKeyPressedTime>20) {
        xKeyPressedTime = 20;
      }
      switch(xKeyStack.get(xKeyStack.size()-1)) {
      case LEFT:
        x-=xKeyPressedTime>>1;
        break;
      case RIGHT:
        x+=xKeyPressedTime>>1;
      }
      int offset = objWidth >> 1;
      if (x < offset) {
        x = offset;
      } else if (x > (640 - offset)) {
        x = 640 - offset;
      }
    }
    if (yKeyStack.size()>0) {
      yKeyPressedTime ++; 
      if (yKeyPressedTime > 20) {
        yKeyPressedTime = 20;
      }
      switch(yKeyStack.get(yKeyStack.size()-1)) {
      case UP:
        y -= yKeyPressedTime >> 1;
        break;          
      case DOWN:
        y += yKeyPressedTime >> 1;
      }
      int offset = objHeight >> 1;
      if (y < offset) {
        y = offset;
      } else if (y > (480 - offset)) {
        y = 480 - offset;
      }
    }
  }

  /**
   * when key released
   */
  public void keyReleasedFun(int keyCode1) {
    if (keyCode1 == LEFT || keyCode1 == RIGHT) {
      xKeyPressedTime = 1;
      for (int i=0; i<xKeyStack.size(); i++) {
        if (xKeyStack.get(i)==keyCode1) {
          xKeyStack.remove(i);
          break;
        }
      }
    }
    if (keyCode1 == UP||keyCode1 == DOWN) {
      yKeyPressedTime = 1;
      for (int i=0; i<yKeyStack.size(); i++) {
        if (yKeyStack.get(i)==keyCode1) {
          yKeyStack.remove(i);
          break;
        }
      }
    }
  }

  /**
   * when key pressed
   */
  public void keyPressedFun(int keyCode1) {
    if (keyCode1 == LEFT || keyCode1 == RIGHT) {
      if (xKeyStack.size()==0 || xKeyStack.get(xKeyStack.size()-1)-keyCode1 != 0) {
        xKeyStack.add(keyCode1);
      }
    }
    if (keyCode1 == UP||keyCode1 == DOWN) {
      if (yKeyStack.size()==0 || yKeyStack.get(yKeyStack.size()-1)-keyCode1 != 0) {
        yKeyStack.add(keyCode1);
      }
    }
  }
}

//================================================================================================================
//================================================================================================================

class Treasure extends DrawingOBJ {

  private Fighter target = null;
  private GameDataChanged listener;

  public Treasure(Fighter target, GameDataChanged listener) {
    super(40, 40, resourcesManager.get(ResourcesManager.treasure), ObjType.TREASURE);
    this.listener = listener;
    this.target = target;
    randomTreasure();
  }

  public void SpecialDraw() {
  }

  public void doGameLogic() {
    if (target != null) {
      if (isHitOBJ(target)) {
        if (listener != null) {
          listener.addHP(10);
        }
        randomTreasure();
      }
    }
  }

  /**
   * to random an treasure
   */
  public void randomTreasure() {
    // x is from 20 to 620
    // y is from 20 to 460
    do {
      x = floor(random(600)+20);
      y = floor(random(440)+20);
    } while (isHitOBJ(target));
  }
}

//================================================================================================================
//================================================================================================================

class Enemy extends DrawingOBJ {

  protected boolean isInTeam;
  private Fighter target = null;
  private Bullet[] bulletArray;
  private GameDataChanged listener;
  private int hp, maxHP;

  public Enemy(Bullet[] bulletArray, Fighter target, GameDataChanged listener, int level) {
    super(60, 60, resourcesManager.get(ResourcesManager.enemy), ObjType.ENEMY);
    this.listener = listener;
    this.target = target;
    this.bulletArray = bulletArray;
    isInTeam = false;
    randomEnemy(true);
    xSpeed = floor(xSpeed * (level/50f+1));
    maxHP = 1;
    hp = maxHP;
  }

  public void setIsInTeam(boolean isInTeam) {
    this.isInTeam = isInTeam;
    maxHP = 1;
    hp = maxHP;
    img =  resourcesManager.get(ResourcesManager.enemy);
  }

  public void SpecialDraw() {
  }

  public void doGameLogic() {
    if (x < -objWidth) {
      showAlarm();
    } else {
      normalMove();
    }
  }

  public void updateLocation() {
    if (x < -objWidth) {
      x+=1;
    } else {
      super.updateLocation();
    }
  }

  private void normalMove() {
    // normal moves
    if (!isInTeam) {
      if (x < target.x) {
        moveToOBJ(target);
      } else {
        moveToOBJ(this);
      }
    }
    if (this.isHitOBJ(target)) {
      if (listener != null) {
        listener.subHP(20, this);
        listener.enemyMoveOut(this, false);
      }
    }
    if (bulletArray!=null) {
      for (int i=0; i<5; i++) {
        Bullet target = bulletArray[i];
        if (target.isHitOBJ(this)) {
          hp --;
          light = floor(255f / maxHP * hp);
          if (hp <= 0) {
            listener.enemyMoveOut(this, true);
          }
          target.setDisabled();
          break;
        }
      }
    }

    if (listener != null) {
      if (x>= 640) {
        listener.enemyMoveOut(this, false);
      }
    }
  }

  private void showAlarm() {
    // wait 100 times, show warning and speed 
    float temp = (- objWidth - x);
    if (temp < 100) {
      int tSize = floor(20 * (1 - (- objWidth - x) / 100f) + 5);
      textAlign(LEFT);
      textSize(16);
      // draw different color with different speed
      if (xSpeed > 20 ) {
        drawStrokeText("" + xSpeed, color(255, 0, 0), #ffffff, 25, floor(y+ 8), 1);
      } else if (xSpeed > 10) {
        // 10 - 20 yellow to red
        drawStrokeText("" + xSpeed, color(255, 255 - floor((xSpeed-10)/10f * 255), 0), #ffffff, 25, floor(y+ 8), 1);
      } else {
        // 1 - 10 green to yellow
        drawStrokeText("" + xSpeed, color(floor((xSpeed)/10f * 255), 255, 0), #ffffff, 25, floor(y+ 8), 1);
      }
      textSize(tSize);
      drawStrokeText("!", #ff0000, #ffffff, 10, floor(y + (tSize >> 1)), 1);
    }
  }

  private void randomEnemy(boolean isAvoidFighter) {
    x = -100 - objWidth;
    xSpeed = floor(random(1, 5));
    ySpeed =0;
    do {
      y = floor(random(0, 450));
      // if need avoid fighter and enemy is in fighter line then random again
    } while (isAvoidFighter && isInTargetLine(target));
  }

  private boolean isInTargetLine(Fighter obj) {
    int yOffset = objHeight >> 1 ;
    int yOffset1 = obj.objHeight >>1;
    int top =floor(y + yOffset), bottom =floor(y - yOffset);
    int tt =floor(obj.y + yOffset1), tb = floor(obj.y - yOffset1);
    if ((bottom < tt)&&(top > tb)) {
      return true;
    }
    return false;
  }
}

//================================================================================================================
//================================================================================================================

class GameTitle extends DrawingOBJ {

  public int hp = 0, score = 0;

  public GameTitle() {
    super(0, 0, resourcesManager.get(ResourcesManager.hp), ObjType.TITLE);
    x = 10;
    y = 10;
  }

  public void SpecialDraw() {
    textSize(15);
    textAlign(CENTER);
    drawStrokeText(hp + "", #ffffff, #000000, floor(x + 112), floor(y + 17), 1);
    drawScore();
  }

  public void doGameLogic() {
    if (hp< 0 ) {
      hp = 0;
    } else if (hp>100) {
      hp = 100;
    }
    color hpColor ;
    float hpVal = hp;
    int curhp = floor(194f * hp / 100f);
    if (hp > 50) {
      int val = 255 - floor((hpVal - 50f) / 50f * 255f);
      hpColor = color(val, 255, 0);
    } else {
      int val = floor(hpVal / 50f * 255f);
      hpColor = color(255, val, 0);
    }
    drawHPBar(hpColor, curhp);
  }

  private void drawHPBar(color barColor, int barWidth) {
    stroke(barColor);
    fill(barColor);
    rect( x + 12, y + 4, barWidth, 16);
  }

  /**
   * to draw the value of level
   */
  private void drawScore() {
    textSize(15);
    textAlign(RIGHT);
    drawStrokeText("Score:" + score, #ffffff, #000000, 70, 470, 1);
  }
}


//================================================================================================================
//================================================================================================================

class FrameAnimation extends DrawingOBJ {

  public int delay = 100;

  private PImage[] expArray;
  private int timer, shownID, frameCnt;
  private GameDataChanged listener;
  private DrawingOBJ targetOBJ;

  private void initSystem(GameDataChanged listener, int startID, int frameCnt) {
    this.listener = listener;
    this.frameCnt = frameCnt;
    setIsDrawSelf(false);
    expArray = new PImage[frameCnt];
    for (int i = 0; i<frameCnt; i++) {
      expArray[i] = resourcesManager.get(startID + i);
    }
    timer = 0;
    shownID = -1;
  }

  public FrameAnimation(GameDataChanged listener, int startID) {
    super(64, 64, null, ObjType.TITLE);
    initSystem(listener, startID, 5);
  }

  public FrameAnimation(GameDataChanged listener, int startID, int frameWidth, int frameHeight) {
    super(frameWidth, frameHeight, null, ObjType.TITLE);
    initSystem(listener, startID, 5);
  }

  public FrameAnimation(GameDataChanged listener, int startID, int frameWidth, int frameHeight, int frameCnt) {
    super(frameWidth, frameHeight, null, ObjType.TITLE);
    initSystem(listener, startID, frameCnt);
  }

  public void bindingOBJ(DrawingOBJ target) {
    targetOBJ = target;
    x = target.x;
    y = target.y;
    xSpeed = target.xSpeed;
    ySpeed = target.ySpeed;
  }

  public void SpecialDraw() {
    if (shownID<frameCnt) {
      image(expArray[shownID], x-(objWidth>>1), y-(objHeight>>1));
    } else if (listener != null) {
      listener.FrameAnimationFinished(this);
    } else {
      image(expArray[0], x-(objWidth>>1), y-(objHeight>>1));
      timer = millis();
    }
  }

  public void doGameLogic() {
    if (timer == 0 ) {
      timer = millis();
    }
    shownID = floor((millis() - timer)/delay);
    if (targetOBJ != null) {
      if (targetOBJ.classID == ObjType.FIGHTER) {
        x = targetOBJ.x;
        y = targetOBJ.y;
      }
    }
  }
}

//================================================================================================================
//================================================================================================================

class Bullet extends DrawingOBJ {

  private boolean isEnabled;
  private DrawingOBJ target;

  public Bullet(DrawingOBJ target) {
    super(31, 27, resourcesManager.get(ResourcesManager.bullet), ObjType.BULLET);
    this.target = target;
    isEnabled = false;
    xSpeed = 10;
  }

  public boolean shoot() {
    if (isEnabled) {
      return false;
    } else {
      isEnabled = true;
      x = target.x;
      y = target.y;
      xSpeed = 10;
      ySpeed = 0;
    }
    return true;
  }
  //*
  public void SpecialDraw() {
  }//*/

  public void doGameLogic() {
    isEnabled = (x>-objWidth);
    setIsDrawSelf(isEnabled);
  }

  public void setDisabled() {
    isEnabled = false;
    x = -1-objWidth;
  }

  public void updateLocation() {
    if (isEnabled) {
      x -= xSpeed;
      y -= ySpeed;
    }
  }

  public boolean isBulletEnabled() {
    return isEnabled;
  }

  public boolean isHitOBJ(DrawingOBJ obj) {
    return (isEnabled && (super.isHitOBJ(obj, 0, 10)));
  }
}

//================================================================================================================
//================================================================================================================

class OnGaming extends Screen implements KeyPressListener, GameDataChanged {

  private final int SHOOT_DELAY = 100;

  public int score, hp;
  private long lastShootTime;
  private int bg2x = 640, teamCnt, teamId, listChangeCnt;
  private boolean fighting, added;
  private ArrayList<DrawingOBJ>  drawingArray;
  private Fighter fighter = null;
  private GameTitle title = null;
  private Bullet[] bulletArray;

  private void initVariables() {
    fighting = false;
    drawingArray = new ArrayList();
    hp = 20;
    score = 0;
    teamId = 0;
    xSpeed = 5;
    listChangeCnt = 0;
    lastShootTime = 0;
  }

  private void initComponents() {
    fighter = new Fighter();
    fighter.setHP(hp) ;
    fighter.zOrder = 2;
    drawingArray.add(fighter);

    title = new GameTitle();
    title.hp = hp;
    title.zOrder = 4;
    drawingArray.add(title);

    Treasure t = new Treasure(fighter, this);
    t.zOrder = 3;
    drawingArray.add(t);

    bulletArray = new Bullet[5];
    for (int i = 0; i < 5; i++) {
      Bullet temp = new Bullet(fighter);
      temp.zOrder = 1;
      bulletArray[i]= temp;
      drawingArray.add(temp);
    }
  }

  public OnGaming(ScreenChangeListener listener) {
    super(resourcesManager.get(ResourcesManager.bg1), listener);
    initVariables();
    initComponents();
    randomTeam();
  }

  public void SpecialDraw() {
    // sort drawing array by z order
    for (int i = 0; i < drawingArray.size(); i++) {
      for (int j = i+1; j < drawingArray.size(); j++) {
        if (drawingArray.get(i).zOrder > drawingArray.get(j).zOrder) {
          DrawingOBJ temp = drawingArray.get(i);
          drawingArray.set(i, drawingArray.get(j));
          drawingArray.set(j, temp);
        }
      }
    }
    //do logic and draw objects
    for (int i = 0; (i < drawingArray.size()) && (i>-1); i++) {
      drawingArray.get(i).drawFrame();
      if (listChangeCnt>0) {
        i -= listChangeCnt;
        listChangeCnt = 0;
      }
    }
  }

  public void doGameLogic() {
    doBackgroundLogic();
    // add a special enemy each 20 level
    boolean isSpealLevel = false;//(level%20 == 0);
    if ((score>-1)&&(isSpealLevel)&&(!added)) {
      added = true;
      drawingArray.add(new Enemy(bulletArray, fighter, this, score));
    } else if (added&&(!isSpealLevel)) {
      added = false;
    }
    // end the game while hp is under zero
    if (hp <= 0) {
      listener.endGame(score);
    }
    // fire logic
    if (fighting) {
      long timeErr = millis() - lastShootTime;
      if (timeErr>SHOOT_DELAY) {
        boolean isShoot =false;
        for (int i=0; (i<5); i++) {
          isShoot = bulletArray[i].shoot();
          if (isShoot) {
            lastShootTime = millis();
            timeErr = 0;
            break;
          }
        }
      }
    }
    // make bullets follow enemy
    bulletFollow();
  }

  private int closestEnemy(float x, float y) {
    int ret = -1;
    float minDestance = 999;
    for (int i = 0; (i < drawingArray.size()); i++) {
      DrawingOBJ temp = drawingArray.get(i);
      if (temp.classID == ObjType.ENEMY) {
        float destance = temp.getDestanceBetweenOBJ(floor(x), floor(y));
        if (temp.x < x && temp.x > 0) {
          if (destance < minDestance) {
            minDestance = destance;
            ret = i;
          }
        }
      }
    }
    return ret;
  }

  private void bulletFollow() {
    for (Bullet i : bulletArray) {
      if (i.isBulletEnabled()) {
        float bulletA = 0.2;
        int index = closestEnemy(i.x, i.y);
        if (index > -1) {
          DrawingOBJ temp = drawingArray.get(index);
          i.moveToOBJ(temp, bulletA);
        } else {
          i.moveToOBJ(i, bulletA);
        }
      }
    }
  }

  private void addEnemyInTeam(int x_offset, int y, int speed) {
    Enemy newEnemy = new Enemy(bulletArray, fighter, this, score);
    newEnemy.x = newEnemy.x - x_offset;
    newEnemy.y = y;
    newEnemy.xSpeed = speed;
    newEnemy.setIsInTeam(true);
    drawingArray.add(newEnemy);
  }

  private void randomTeam() {
    int yy;
    int s = floor(random(1, 5) * (score / 1000f+1));
    if (teamId==0) {
      yy= floor(random(420)+30);
      teamCnt = 5;
      for (int i =0; i<teamCnt; i++) {
        addEnemyInTeam(60*i/s, yy, s);
      }
    } else if (teamId==1) {
      yy= floor(random(220)+30);
      teamCnt = 5;
      for (int i =0; i<teamCnt; i++) {
        addEnemyInTeam(60*i/s, yy+50*i, s);
      }
    } else {
      yy= floor(random(220)+130);
      teamCnt = 8;
      addEnemyInTeam(0, yy, s);
      addEnemyInTeam(60/s, yy-50, s);
      addEnemyInTeam(60/s, yy+50, s);
      addEnemyInTeam(120/s, yy-100, s);
      addEnemyInTeam(120/s, yy+100, s);
      addEnemyInTeam(180/s, yy-50, s);
      addEnemyInTeam(180/s, yy+50, s);
      addEnemyInTeam(240/s, yy, s);
    }
    teamId++;
    if (teamId>2) {
      teamId = 0;
    }
  }

  public void updateLocation() {
  }

  private void doBackgroundLogic() {
    x = moveBG(floor(x));
    bg2x = moveBG(bg2x);
    image(resourcesManager.get(ResourcesManager.bg2), bg2x, y);
  }

  private int moveBG(int curX) {
    // the more level the more quick background moves
    int speedOffset = score / 200;
    int maxOffset = floor(xSpeed * 2);
    if (speedOffset> maxOffset) {
      speedOffset = maxOffset;
    }
    curX +=640 + xSpeed + speedOffset;
    curX %= 1280;
    curX -= 640;
    return curX;
  }


  /**
   * when key released
   */
  public void keyReleasedFun(int keyCode1) {
    fighter.keyReleasedFun(keyCode1);
    if (keyCode1 == 32) {
      fighting = false;
    }
  }

  /**
   * when key pressed
   */
  public void keyPressedFun(int keyCode1) {
    fighter.keyPressedFun(keyCode1);
    if (keyCode1 == 32) {
      if (fighting == false) {
        lastShootTime = millis() - SHOOT_DELAY -1;
      }
      fighting = true;
    }
  }


  public void addHP(int val) {
    hp += val;
    if (hp > 100) {
      hp = 100;
    }    
    syncInfo();
  }

  public void subHP(int val, DrawingOBJ target) {
    hp -= val;
    if (hp < 0) {
      hp = 0;
    }

    FrameAnimation explode = new FrameAnimation(this, ResourcesManager.explode, 81, 81);
    explode.bindingOBJ(fighter);
    explode.zOrder = 3;
    drawingArray.add(explode);

    syncInfo();
  }

  public void FrameAnimationFinished(FrameAnimation target) {
    drawingArray.remove(target);
    listChangeCnt ++;
    target = null;
  }

  public void enemyMoveOut(Enemy target, boolean showFrameAnimation) {
    drawingArray.remove(target);
    if (target.isInTeam) {
      if (--teamCnt==0) {
        randomTeam();
      }
    }
    if (showFrameAnimation) {
      FrameAnimation explode = new FrameAnimation(this, ResourcesManager.explode, 81, 81);
      explode.bindingOBJ(target);
      explode.zOrder = 3;
      drawingArray.add(explode);
      score += 20;
      syncInfo();
    }

    listChangeCnt ++;
    if (!target.isInTeam) {    
      drawingArray.add(new Enemy(bulletArray, fighter, this, score));
    }
    target = null;
  }

  public void drawFrame() {
    doGameLogic();
    int half_height = objHeight>>1;
    int half_width = objWidth>>1;
    image(super.img, x - half_width, y - half_height);    
    SpecialDraw();
  }

  private void syncInfo() {
    title.hp = hp;
    title.score= score;
    fighter.setHP(hp);
  }
}

//================================================================================================================
//================================================================================================================

class GameStart extends Screen implements MouseListener {

  private boolean isOnButton, isPressButton;
  private int alpha, alpha_offset ;

  public GameStart(ScreenChangeListener listener) {
    super(resourcesManager.get(ResourcesManager.st2), listener);
    alpha_offset = 10;
    alpha = 0;
  }

  public void SpecialDraw() {
    if (isOnButton && (! isPressButton)) {
      image(img, x, y);
      tint(255, alpha);
      image(resourcesManager.get(ResourcesManager.st1), 0, 0);
      tint(255, 255);
      alpha += alpha_offset;
      if (alpha>255) {
        alpha = 255;
        alpha_offset = -alpha_offset;
      } else if (alpha<100) {
        alpha = 100;
        alpha_offset = -alpha_offset;
      }
    }
  }

  public void doGameLogic() {
    setIsDrawSelf((!isOnButton) ||isPressButton);
  }


  public void mouseReleasedFun(int keyCode1) {
    if (keyCode1 == MOUSE_LEFT) {
      isPressButton = false;
      if (isOnButton && listener != null) {
        listener.startGame();
      }
    }
  }
  public void mousePressedFun(int keyCode1) {
    if (keyCode1 == MOUSE_LEFT) {
      isPressButton = true;
    }
  }
  public void mouseMovedFun(int x, int y) {
    boolean newBool = isPointHitArea(x, y, 210, 380, 450, 410);
    if (newBool!=isOnButton) {
      alpha_offset = 10;
      alpha = 0;
    }
    isOnButton =  newBool;
  }
}

//================================================================================================================
//================================================================================================================

class GameEnd extends Screen implements MouseListener {

  public int level = 0;
  private boolean isOnButton, isPressButton;
  private int alpha, alpha_offset ;

  public GameEnd(ScreenChangeListener listener) {
    super(resourcesManager.get(ResourcesManager.end2), listener);
    isOnButton = false;
    isPressButton = false;
  }

  public void SpecialDraw() {
    if (isOnButton && (! isPressButton)) {
      tint(255, alpha);
      image(resourcesManager.get(ResourcesManager.end1), 0, 0);
      tint(255, 255);
      alpha += alpha_offset;
      if (alpha>255) {
        alpha = 255;
        alpha_offset = -alpha_offset;
      } else if (alpha<100) {
        alpha = 100;
        alpha_offset = -alpha_offset;
      }
    }
    textAlign(CENTER);
    textSize(30);
    drawStrokeText("Final Score:"+level, #ffffff, #ff0000, 320, 220, 2);
  }

  public void doGameLogic() {
    setIsDrawSelf((!isOnButton) ||isPressButton);
  }

  public void drawFrame() {
    doGameLogic();
    image(resourcesManager.get(ResourcesManager.end2), 0, 0);
    SpecialDraw();
  }

  public void mouseReleasedFun(int keyCode1) {
    if (keyCode1 == MOUSE_LEFT) {
      isPressButton = false;
      if (isOnButton && listener != null) {
        listener.restartGame();
      }
    }
  }
  public void mousePressedFun(int keyCode1) {
    if (keyCode1 == MOUSE_LEFT) {
      isPressButton = true;
    }
  }
  public void mouseMovedFun(int x, int y) {
    boolean newBool = isPointHitArea(x, y, 210, 310, 435, 345);
    if (newBool!=isOnButton) {
      alpha_offset = 10;
      alpha = 0;
    }
    isOnButton =  newBool;
  }
}
