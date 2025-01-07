class Menu {
  color buttonColor;
  color buttonHoverColor;
  color textColor;
  PVector buttonPos;
  PVector buttonSize;
  boolean isActive;
  boolean isGameOver;
  String title;
  float titleScale;
  float animationOffset;
  int finalScore;
  PVector restartButtonPos;
  PVector menuButtonPos;
  
  Menu() {
    buttonColor = color(120, 70, 70);
    buttonHoverColor = color(120, 80, 80);
    textColor = color(0, 0, 100);
    buttonPos = new PVector(width/2, height/2);
    buttonSize = new PVector(200, 50);
    restartButtonPos = new PVector(width/2, height/2 + 20);
    menuButtonPos = new PVector(width/2, height/2 + 80);
    isActive = true;
    isGameOver = false;
    title = "SNAKE GAME";
    titleScale = 1.0;
    animationOffset = 0;
    finalScore = 0;
  }
  
  void update() {
    if (!isActive && !isGameOver) return;
    
    // Анимация пульсации заголовка
    titleScale = 1.0 + sin(frameCount * 0.05) * 0.1;
    
    // Анимация змейки
    animationOffset += 0.1;
  }
  
  void show() {
    if (!isActive && !isGameOver) return;
    
    background(51);
    
    if (isGameOver) {
      showGameOver();
    } else {
      showMainMenu();
    }
  }
  
  void showMainMenu() {
    // Рисуем заголовок
    pushMatrix();
    textAlign(CENTER, CENTER);
    textSize(40 * titleScale);
    fill(textColor);
    text(title, width/2, height/4);
    popMatrix();
    
    // Рисуем декоративную змейку
    drawDecorativeSnake();
    
    // Рисуем кнопку
    boolean isHovered = isMouseOverButton(buttonPos);
    fill(isHovered ? buttonHoverColor : buttonColor);
    noStroke();
    rectMode(CENTER);
    rect(buttonPos.x, buttonPos.y, buttonSize.x, buttonSize.y, 10);
    
    // Текст кнопки
    fill(textColor);
    textAlign(CENTER, CENTER);
    textSize(20);
    text("START GAME", buttonPos.x, buttonPos.y);
    
    // Рисуем инструкции
    textSize(16);
    text("Use arrow keys to control the snake", width/2, height*0.7);
    text("Collect apples to grow", width/2, height*0.75);
    text("Super food appears every 5 apples", width/2, height*0.8);
  }
  
  void showGameOver() {
    // Заголовок Game Over
    textAlign(CENTER, CENTER);
    textSize(50 * titleScale);
    fill(0, 100, 100); // Красный цвет
    text("GAME OVER", width/2, height/4);
    
    // Показываем счет
    textSize(30);
    fill(textColor);
    text("Score: " + finalScore, width/2, height/3);
    
    // Кнопка Restart
    boolean isRestartHovered = isMouseOverButton(restartButtonPos);
    fill(isRestartHovered ? buttonHoverColor : buttonColor);
    rectMode(CENTER);
    rect(restartButtonPos.x, restartButtonPos.y, buttonSize.x, buttonSize.y, 10);
    
    // Кнопка Main Menu
    boolean isMenuHovered = isMouseOverButton(menuButtonPos);
    fill(isMenuHovered ? buttonHoverColor : buttonColor);
    rect(menuButtonPos.x, menuButtonPos.y, buttonSize.x, buttonSize.y, 10);
    
    // Текст кнопок
    fill(textColor);
    textSize(20);
    text("RESTART", restartButtonPos.x, restartButtonPos.y);
    text("MAIN MENU", menuButtonPos.x, menuButtonPos.y);
  }
  
  void drawDecorativeSnake() {
    // Рисуем декоративную змейку, которая двигается по синусоиде
    float x = width/4;
    float baseY = height/2;
    float amplitude = 50;
    float frequency = 0.1;
    
    for (int i = 0; i < 10; i++) {
      float y = baseY + sin((x + i * 20) * frequency + animationOffset) * amplitude;
      if (i == 0) {
        // Голова змеи
        fill(120, 80, 70);
        ellipse(x + i * 20, y, 25, 25);
        // Глаза
        fill(0);
        ellipse(x + i * 20 + 5, y - 5, 5, 5);
        ellipse(x + i * 20 + 5, y + 5, 5, 5);
      } else {
        // Тело змеи
        fill(120, 70 + i * 2, 60);
        ellipse(x + i * 20, y, 20, 20);
      }
    }
  }
  
  boolean isMouseOverButton(PVector pos) {
    return mouseX > pos.x - buttonSize.x/2 && 
           mouseX < pos.x + buttonSize.x/2 && 
           mouseY > pos.y - buttonSize.y/2 && 
           mouseY < pos.y + buttonSize.y/2;
  }
  
  void mousePressed() {
    if (!isActive && !isGameOver) return;
    
    if (isGameOver) {
      if (isMouseOverButton(restartButtonPos)) {
        isGameOver = false;
        isActive = false;
        startGame();
      } else if (isMouseOverButton(menuButtonPos)) {
        isGameOver = false;
        isActive = true;
        loop(); // Возобновляем игровой цикл
      }
    } else if (isActive && isMouseOverButton(buttonPos)) {
      isActive = false;
      startGame();
    }
  }
  
  void setGameOver(int score) {
    isGameOver = true;
    finalScore = score;
  }
}
