int cols, rows;
int scale = 25;
Snake snake;
Food food;
SuperFood superFood;
boolean isSuperFoodActive = false;
int normalFoodCounter = 0;
PGraphics appleImg;
PGraphics headImg;
Menu menu;
boolean gameStarted = false;

void setup() {
  size(400, 400);
  cols = width / scale;
  rows = height / scale;
  frameRate(7);
  colorMode(HSB, 360, 100, 100);
  menu = new Menu();
  createImages(); // Создаем изображения заранее
}

void createImages() {
  // Создаем изображение яблока
  appleImg = createGraphics(scale, scale);
  appleImg.beginDraw();
  appleImg.clear();
  appleImg.colorMode(HSB, 360, 100, 100);
  // Рисуем яблоко
  appleImg.noStroke();
  appleImg.fill(0, 100, 100);  // Красный
  appleImg.ellipse(scale/2, scale/2, scale*0.8, scale*0.8);
  // Добавляем блик
  appleImg.fill(0, 50, 100);
  appleImg.ellipse(scale/3, scale/3, scale/3, scale/3);
  // Добавляем листик
  appleImg.fill(120, 100, 80);
  appleImg.pushMatrix();
  appleImg.translate(scale/2, scale/4);
  appleImg.rotate(PI/6);
  appleImg.ellipse(0, 0, scale/3, scale/4);
  appleImg.popMatrix();
  appleImg.endDraw();
  
  // Создаем изображение головы змеи
  headImg = createGraphics(scale, scale);
  headImg.beginDraw();
  headImg.clear();
  headImg.colorMode(HSB, 360, 100, 100);
  // Основная форма головы
  headImg.fill(120, 80, 70);
  headImg.noStroke();
  headImg.ellipse(scale/2, scale/2, scale*0.9, scale*0.9);
  // Глаза
  headImg.fill(0);
  headImg.ellipse(scale*0.7, scale*0.3, scale*0.2, scale*0.2);
  headImg.ellipse(scale*0.7, scale*0.7, scale*0.2, scale*0.2);
  // Язык
  headImg.fill(0, 100, 100);
  headImg.pushMatrix();
  headImg.translate(scale*0.9, scale/2);
  headImg.rotate(PI/6);
  headImg.rect(0, -scale*0.1, scale*0.3, scale*0.2);
  headImg.popMatrix();
  headImg.endDraw();
}

void draw() {
  if (!gameStarted) {
    menu.update();
    menu.show();
  } else {
    gameLoop();
  }
}

void gameLoop() {
  background(51);
  snake.update();
  snake.show();
  
  if (snake.eat(food)) {
    food.pickLocation();
    normalFoodCounter++;
    
    if (normalFoodCounter % 5 == 0) {
      isSuperFoodActive = true;
      superFood.pickLocation();
    }
  }
  
  if (isSuperFoodActive && snake.eatSuper(superFood)) {
    isSuperFoodActive = false;
  }
  
  food.show();
  if (isSuperFoodActive) {
    superFood.show();
  }
  
  if (snake.checkCollision()) {
    println("Game Over! Score: " + snake.getScore());
    gameOver();
  }
}

void startGame() {
  snake = new Snake();
  food = new Food();
  superFood = new SuperFood();
  normalFoodCounter = 0;
  isSuperFoodActive = false;
  gameStarted = true;
}

void gameOver() {
  gameStarted = false;
  menu.setGameOver(snake.getScore());
}

void mousePressed() {
  menu.mousePressed();
  if (gameStarted) {
    loop(); // Возобновляем игровой цикл если игра запущена
  }
}

void keyPressed() {
  if (!gameStarted) return;
  
  int newX = 0;
  int newY = 0;
  
  switch(keyCode) {
    case UP:
      newX = 0;
      newY = -1;
      break;
    case DOWN:
      newX = 0;
      newY = 1;
      break;
    case LEFT:
      newX = -1;
      newY = 0;
      break;
    case RIGHT:
      newX = 1;
      newY = 0;
      break;
  }
  
  if ((newX != 0 || newY != 0) && !snake.isOppositeDirection(newX, newY)) {
    snake.setDirection(newX, newY);
  }
}

class Snake {
  ArrayList<PVector> body;
  ArrayList<PVector> smoothBody;
  ArrayList<Color> colors;
  PVector dir;
  int total;
  int score;
  float smoothSpeed = 0.5;
  float headAngle = 0;
  
  class Color {
    float hue;
    float sat;
    float bri;
    
    Color(float h, float s, float b) {
      hue = h;
      sat = s;
      bri = b;
    }
  }
  
  Snake() {
    body = new ArrayList<PVector>();
    smoothBody = new ArrayList<PVector>();
    colors = new ArrayList<Color>();
    PVector start = new PVector(floor(cols / 2), floor(rows / 2));
    body.add(start);
    smoothBody.add(start.copy());
    colors.add(new Color(120, 80, 70));
    dir = new PVector(0, 0);
    total = 0;
    score = 0;
  }
  
  Color generateNewColor() {
    float hue = 120;
    float sat = random(70, 90);
    float bri = random(40, 85);
    return new Color(hue, sat, bri);
  }
  
  int getScore() {
    return score;
  }
  
  boolean isOppositeDirection(int newX, int newY) {
    return (newX != 0 && newX == -dir.x) || (newY != 0 && newY == -dir.y);
  }
  
  void setDirection(int x, int y) {
    dir.x = x;
    dir.y = y;
  }
  
  void grow(int amount) {
    total += amount;
    score += amount;
  }
  
  void update() {
    if (dir.x != 0 || dir.y != 0) {
      if (total > body.size() - 1) {
        PVector tail = body.size() > 0 ? body.get(body.size() - 1).copy() : new PVector(body.get(0).x, body.get(0).y);
        body.add(tail);
        smoothBody.add(tail.copy());
        colors.add(generateNewColor());
      }
      
      for (int i = body.size() - 1; i > 0; i--) {
        body.set(i, body.get(i - 1).copy());
      }
      
      PVector head = body.get(0);
      head.x += dir.x;
      head.y += dir.y;
      
      if (smoothBody.size() != body.size()) {
        smoothBody.clear();
        for (PVector pos : body) {
          smoothBody.add(pos.copy());
        }
      }
      
      smoothBody.get(0).set(body.get(0));
      
      for (int i = 1; i < smoothBody.size(); i++) {
        PVector target = body.get(i);
        PVector current = smoothBody.get(i);
        
        float distance = PVector.dist(current, target);
        float adjustedSpeed = smoothSpeed * (1 + distance * 0.5);
        adjustedSpeed = min(adjustedSpeed, 1.0);
        
        smoothBody.set(i, PVector.lerp(current, target, adjustedSpeed));
      }
      
      if (frameCount % 5 == 0) {
        for (int i = 1; i < colors.size(); i++) {
          if (random(1) < 0.1) {
            colors.set(i, generateNewColor());
          }
        }
      }
    }
  }
  
  void show() {
    if (body.size() > 1) {
      for (int i = 0; i < smoothBody.size() - 1; i++) {
        PVector current = smoothBody.get(i);
        PVector next = smoothBody.get(i + 1);
        Color currentColor = colors.get(i);
        stroke(currentColor.hue, currentColor.sat, currentColor.bri);
        strokeWeight(scale - 2);
        line(current.x * scale + scale / 2, current.y * scale + scale / 2,
             next.x * scale + scale / 2, next.y * scale + scale / 2);
      }
    }
    
    for (int i = 1; i < smoothBody.size(); i++) {
      PVector segment = smoothBody.get(i);
      Color segmentColor = colors.get(i);
      
      fill(segmentColor.hue, segmentColor.sat, segmentColor.bri);
      noStroke();
      ellipse(segment.x * scale + scale / 2, segment.y * scale + scale / 2, scale, scale);
      
      fill(segmentColor.hue, segmentColor.sat * 0.5, min(segmentColor.bri * 1.3, 100));
      ellipse(segment.x * scale + scale/3, segment.y * scale + scale/3, scale/3, scale/3);
    }
    
    // Отдельно рисуем голову
    if (smoothBody.size() > 0) {
      PVector head = smoothBody.get(0);
      
      // Обновляем угол поворота головы
      if (dir.x > 0) headAngle = 0;
      else if (dir.x < 0) headAngle = PI;
      else if (dir.y > 0) headAngle = HALF_PI;
      else if (dir.y < 0) headAngle = -HALF_PI;
      
      pushMatrix();
      translate(head.x * scale + scale/2, head.y * scale + scale/2);
      rotate(headAngle);
      imageMode(CENTER);
      image(headImg, 0, 0);
      popMatrix();
    }
  }
  
  boolean eat(Food f) {
    PVector head = body.get(0);
    if (head.x == f.pos.x && head.y == f.pos.y) {
      grow(1);
      return true;
    }
    return false;
  }
  
  boolean eatSuper(SuperFood sf) {
    PVector head = body.get(0);
    for (PVector pos : sf.getOccupiedPositions()) {
      if (head.x == pos.x && head.y == pos.y) {
        grow(2);
        return true;
      }
    }
    return false;
  }
  
  boolean checkCollision() {
    PVector head = body.get(0);
    
    if (head.x < 0 || head.y < 0 || head.x >= cols || head.y >= rows) {
      return true;
    }
    
    for (int i = 4; i < body.size(); i++) {
      PVector part = body.get(i);
      if (head.x == part.x && head.y == part.y) {
        return true;
      }
    }
    return false;
  }
}

class Food {
  PVector pos;
  float rotation = 0;
  
  Food() {
    pos = new PVector(0, 0);
    pickLocation();
  }
  
  void pickLocation() {
    pos.x = floor(random(cols));
    pos.y = floor(random(rows));
  }
  
  void show() {
    pushMatrix();
    translate(pos.x * scale + scale/2, pos.y * scale + scale/2);
    rotate(rotation);
    imageMode(CENTER);
    image(appleImg, 0, 0);
    popMatrix();
    
    rotation += 0.02;
  }
}

class SuperFood {
  PVector pos;
  float angle = 0;
  ArrayList<PVector> occupiedPositions;
  
  SuperFood() {
    pos = new PVector(0, 0);
    occupiedPositions = new ArrayList<PVector>();
  }
  
  ArrayList<PVector> getOccupiedPositions() {
    return occupiedPositions;
  }
  
  void pickLocation() {
    pos.x = floor(random(cols - 1));
    pos.y = floor(random(rows - 1));
    
    occupiedPositions.clear();
    occupiedPositions.add(new PVector(pos.x, pos.y));
    occupiedPositions.add(new PVector(pos.x + 1, pos.y));
    occupiedPositions.add(new PVector(pos.x, pos.y + 1));
    occupiedPositions.add(new PVector(pos.x + 1, pos.y + 1));
  }
  
  void show() {
    pushMatrix();
    translate(pos.x * scale + scale, pos.y * scale + scale);
    rotate(angle);
    
    // Внешняя звезда (золотой цвет)
    fill(45, 100, 100);
    noStroke();
    beginShape();
    float size = scale * 1.8;
    for (int i = 0; i < 5; i++) {
      float ang = TWO_PI * i / 5 - HALF_PI;
      float x = cos(ang) * size;
      float y = sin(ang) * size;
      vertex(x, y);
      
      ang += TWO_PI / 10;
      x = cos(ang) * (size/2);
      y = sin(ang) * (size/2);
      vertex(x, y);
    }
    endShape(CLOSE);
    
    // Внутренний круг (более светлый золотой)
    fill(45, 80, 100);
    ellipse(0, 0, scale, scale);
    
    // Добавляем блики
    fill(45, 30, 100);
    for (int i = 0; i < 5; i++) {
      float ang = TWO_PI * i / 5 + angle;
      float x = cos(ang) * (size/3);
      float y = sin(ang) * (size/3);
      ellipse(x, y, scale/4, scale/4);
    }
    
    popMatrix();
    
    angle += 0.1;
  }
}
