/*
	File Name: BrickBreaker.as
	Programmer:Thomas Leung
	Date: 5/6/2016
	Description: A instance of the brick breaker game amatuerly recreated
*/

package  {
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.sampler.NewObjectSample;
	
	public class BrickBreaker extends Sprite{
		
		//object and variable declaration
		public var player:Paddle;
		public var ball:Ball;
		public var brick:Array = [(BRICKS * moreBricks)];
		public var brickAlive:Array = [BRICKS];
		public var laser:Laser;
		
		//SOUNDS
		public var players:PlayerBounce = new PlayerBounce();
		public var balls:BallDrop = new BallDrop();
		public var wall:WallSound = new WallSound();
		public var brickShatter:BrickBreak = new BrickBreak();
		public var pew:LaserSE = new LaserSE();
		
		//Text
		var lifeCounter:TextField = new TextField;
		var lifeFormat:TextFormat = new TextFormat;
		
		//Timers
		var gameTimer:Timer;
		var ballDelay:Timer;
		
		//Progressive Variables
		var brickDead: int = 0;
		var level:int = 1;
		var moreBricks:int = 1;
		var lives:int = 2;
		
		//Laser
		var laserX:Number;
		var laserY:Number = 580;
		
		//Boolean
		var laserActive:Boolean = false;
		var perfectClear:Boolean = true;
		
		//Constants
		const BRICKS:int = 40;
		
		//CONSTRUCTOR FUNCTION//
		public function BrickBreaker() {
			//instantiate an event listener for a laser to be fired
			stage.addEventListener(KeyboardEvent.KEY_DOWN, fireLaser);
			
			//instantiate a new paddle object for player
			player = new Paddle(330,581,37,39);
			addChild(player);
			stage.addEventListener(Event.ENTER_FRAME, player.moveCheck);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, player.movePaddle);
			stage.addEventListener(KeyboardEvent.KEY_UP, player.stopMove);
			
			//instantiate a new ball object for play
			ball = new Ball(400,540,10,10);
			addChild(ball);
			ballDelay = new Timer(850,1);
			ballDelay.start();
			ballDelay.addEventListener(TimerEvent.TIMER_COMPLETE, ballReset);
			
			//instantiate rows/columns of bricks
			for(var i = 0, x = 4, y = 20; i < BRICKS*moreBricks; i ++, x += 77.8)
			{
				if(x > 780)
				{
					x = 4;
					//if level is less than 7 then these y manipulation will occur
					if(level < 7)
					{
						y += 40*level/moreBricks;
						if(y > 500)
						{
							y = 60;
						}
					}
					//if level is higher or equal to 7, these y manipulations will occur
					else
					{
						y +=10*level/moreBricks;
						if(y > 500)
						{
							y = 50;
						}
					}
				}
				brick[i] = new Bricks(x,y)
				brickAlive[i] = true;
				if(brickAlive[i] == true)
				{
					addChild(brick[i]);
				}
			}
			
			//Instantiate game Timer which will run throughout the game to determine collisions
			gameTimer = new Timer(30);
			gameTimer.start();
			gameTimer.addEventListener(TimerEvent.TIMER, checkCollision);
			
			//Text on screen to display the remaining lives of the player
			lifeFormat.font = "Arial";
			lifeFormat.size = 25;
			lifeFormat.color = 0x000000;
			
			lifeCounter.x = 5;
			lifeCounter.y = 570;
			lifeCounter.autoSize = "left";
			lifeCounter.defaultTextFormat = lifeFormat;
			lifeCounter.text = "Lives: " + lives;
			addChild(lifeCounter);
			
		}	//End of constructor
		
		//GAME OVER//
		/* Checks if the requirements for a gameOver is warranted and if so stop terminate game
		*pre: player lives must be 0 if full functionality is in order, otherwise goes off everytime player paddle misses ball.
		*post: if a gameOver is required, removes event listeners to everything and goes to the highscore screen.
		*/
		function gameOver():void
		{
			//if lives is = to 0 stop movement on all object and remove EventListeners from all objects.
			if(lives == 0)
			{
				gameTimer.stop();
				gameTimer.removeEventListener(TimerEvent.TIMER, checkCollision);
				
				ball.stopMoving();
				stage.removeEventListener(Event.ENTER_FRAME, player.moveCheck);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, player.movePaddle);
				stage.removeEventListener(KeyboardEvent.KEY_UP, player.stopMove);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, fireLaser);
				
				MovieClip(root).level = level;
				MovieClip(root).gotoAndStop("InputScreen");
			}	
		}	//end of gameOver
		
		//NEXT LEVEL//
		/* Resets brickDead value to 0 and addsmore bricks depending on the level reached. 
			Reset Brick positioning and ball positioning
		*pre: all bricks must be destroyed on the screen.
		*post: Bricks will be replaced and the ball will reset positioning and speed.
		*/
		function nextLevel():void
		{
			//instantiate rows/columns of bricks
			for(var i = 0, x = 4, y = 20; i < BRICKS*moreBricks; i ++, x += 77.8)
			{
				if(x > 780)
				{
					x = 4;
					//if level is less than 7 then these y manipulation will occur
					if(level < 7)
					{
						y += 40*level/moreBricks;
						if(y > 500)
						{
							y = 60;
						}
					}
					//if level is higher or equal to 7, these y manipulations will occur
					else
					{
						y +=10*level/moreBricks;
						if(y > 500)
						{
							y = 50;
						}
					}
				}
				
				brick[i] = new Bricks(x,y)
				brickAlive[i] = true;
				if(brickAlive[i] == true)
				{
					addChild(brick[i]);
				}
			}	//end of brick placement
			
			//reset ball positioning
			ball.x = 400;
			ball.y = 540;
			ball.yVel = 10;
			ball.xVel = Math.random()*10;
			ball.stopMoving();
			ballDelay.start();
			
			//reset values
			brickDead = 0;
			perfectClear = true;	
			lifeCounter.text = "Lives: " + lives;
		}	//end of nextLevel
		
		//BALL//
		//Resets ball back into the original position and puts a delay.
		//Pre: screen is either cleared of all bricks or ball hits the bottom of the screen.
		function ballReset(event:TimerEvent):void
		{
			ball.startMoving();
			wall.play();
		}
		
		//LASER//
		//checks to see if a laser is already active and then checks the key input to determine if a new laser should be made
		//pre: player must press the spacebar
		function fireLaser(event:KeyboardEvent):void
		{
			if(laserActive == false)
			{
				if(event.keyCode == 32)
				{
					laserActive = true;
					laserX = player.x + player.width/2 - 10;
					makeLaser();
					pew.play();
				}
			}
		}
		
		//Creates a laser instance when the space bar is pressed.
		//pre: if the requirements are met in the fireLaser function make a new laser instance.
		function makeLaser():void
		{
				laser = new Laser(laserX,laserY, -20);
				addChild(laser);
				laser.startMoving();
		}
		
		//COLLISION DETECTION//
		/*Checks to see if any objects are colliding at certain positioning and takes appropriate action
		*pre: The appropriate timer must be ticking and the specific requirements below must be met if any action should be taken.
		*post: adjust the position and velocity of objects depending on the event.
		*/
		function checkCollision(event:TimerEvent):void
		{
			//PADDLE/WALL//
			//Check for wall paddle collisions and prevents paddle from going off stage
			if(player.x < 0)
			{
				player.x = 0;
			}
			
			if(player.x > 618)
			{
				player.x = 618;
			}//end of paddle/ball collision
			
			//Check Ball wall collision
			if(ball.x < 0)
			{
				ball.x = 0;
				ball.xBounce();
				wall.play();
			}
			
			if(ball.x > 759)
			{
				ball.x = 759;
				ball.xBounce();
				wall.play();
			}
			
			//LASER/TOP//
			if(laserActive == true)
			{
				if(laser.y <0)
				{
					laserActive = false;
					removeChild(laser);
				}
			}
			
			//BALL TOP/BOTTOM STAGE//
			//If the ball hits the bottom of the stage reset ball position and set ball yVelocity to go down
			//Puts a delay on the ball before it starts and gives playerOne a point.
			if(ball.y < 0)
			{
				ball.yBounce();
				wall.play();
			}
			
			//bottom
			if(ball.y > 600)
			{
				ball.x = 400;
				ball.y = 540;
				ball.yVel = 10;
				ball.xVel = Math.random()*10;
				ball.stopMoving();
				ballDelay.start();
				
				lives --;
				gameOver();
				perfectClear = false;
				lifeCounter.text = "Lives: " + lives;
				balls.play();
			}
			
			//PADDLE/BALL// 
			//if the ball hits the paddle the yVelocity changes and the xVelocity changes based off ball and paddle position
			if(ball.hitTestObject(player))
			{
				ball.yBounce();
				ball.xVel = (((ball.x + ball.width) - (player.x) - 100) / 5);
				players.play();
			}
			
			//PADDLE/BRICK//
			//Checks for collision with all instances of the brick array
			for(var h = 0; h < BRICKS*moreBricks; h ++)
			{
				//if collision is detected and the brick is detected as "Alive" ball yVelocity changes
				//brick gets set to dead and is removed from the stage. 
				//brickDead increases in value and if all bricks are dead player proceeds to next level.
				if(ball.hitTestObject(brick[h]))
				{
					//Checks to see if the brick hit is alive or not
					if(brickAlive[h] == true)
					{
						ball.yBounce();
						brickAlive[h] = false;
						//after brick is set to dead remove it from stage
						removeChild(brick[h]);
						
						brickDead ++;
						brickShatter.play();
					}
				}
			}	//end of BRICK/BALL collision
			
			
			if(laserActive == true)
			{
				for(var j = 0; j < BRICKS*moreBricks; j ++)
				{
					
					if(laser.hitTestObject(brick[j]))
					{
						if(brickAlive[j] == true)
						{
							laserActive = false;
							removeChild(laser);
								
							brickAlive[j] = false;
							removeChild(brick[j]);
								
							brickDead ++;
							brickShatter.play();
						}
						
					}
				}
			}	//end of LASER/BRICK collision	
			
			//after all the bricks are removed proceed to next level and receive an extra life if a perfect clear is achieved
			if(brickDead == BRICKS*moreBricks)
			{

				if(perfectClear == true)
				{
					lives ++;
				}
				
				if(laserActive == true)
				{
					removeChild(laser);
					laserActive = false;
				}

				//adds more bricks to stage when level 5 & 7 is reached
				if(level == 4 || level == 6)
				{
					moreBricks++;
					level ++;
					nextLevel();
				}
				else
				{
					level ++;
					nextLevel();
				}
			}
			
		}	//end of checkCollision
		
	}	//End of class
	
}	//End of package