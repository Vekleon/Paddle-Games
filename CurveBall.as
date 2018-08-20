/*
	File Name: CurveBall.as
	Programmer: Thomas Leung
	Date: 19/6/16
	Description: A very horrible put together variation of CurveBall, meant for sadomasochists alike.
*/

package  {
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class CurveBall extends Sprite{
		
		//objects
		public var player:CurvePaddle;
		public var ball:BallCurve;
		public var border:Border;
		public var ai:Ai;
		
		//SOUND EFFECTS
		public var players:PlayerServeCurve = new PlayerServeCurve();
		public var miss:Miss = new Miss();
		public var wall:WallCurve = new WallCurve();
		public var opponent:OpponentBounce = new OpponentBounce();
		
		//timers
		var gameTimer:Timer;
		var borderShrink:Timer;
		var borderGrow:Timer;
		var collisionTimer:Timer;
		var delayTimer:Timer;
		
		//border scaling
		var borderXShrink:Number = 5.2;  //X scale
		var borderYShrink:Number = 3.48; //Y Scale
		var borderWShrink:Number = 10.4; //Width Scale
		var borderHShrink:Number = 6.93; //Height Scale
		
		//border counter
		var scaleCount:int = 0;
		
		var sVel:int = 15; //starting velocity for ball.
		var aiSpeed:int = 5; //the speed of the opposing paddle
		
		var pLives:int = 4; //Player Lives
		var aLives:int = 2; //AI lives
		
		var level:int = 1;
		
		var serving:Boolean = true;
		//var tracing:Boolean = false; removed feature meant to determine when the AI should start following the ball (time constraint).
		
		//Text
		var playerLives:TextField = new TextField;
		var oppLives:TextField = new TextField;
		var levelDisplay:TextField = new TextField;
		var myFormat:TextFormat = new TextFormat;

		//CONSTRUCTORE FUNCTION//
		/* Set Stage Elements into place that are required for a game of CurveBall.
		*pre: Starts as soon as the correct frame is entered.
		*post: Instances of the proper classes are set onto the field with timers to allow for control and play
		*/
		public function CurveBall() {
			//instantiate a new ai for play
			ai = new Ai((stage.width/2),(stage.height/2))
			addChild(ai);
			
			
			//instantiate a new ball object for play
			ball = new BallCurve((stage.width/2),(stage.height/2), sVel, sVel);
			addChild(ball);
			
			//instantiate a new paddle object for player
			player = new CurvePaddle(mouseX, mouseY);
			addChild(player);
			player.alpha = .8;
			
			//instantiate a new border
			border = new Border(29.45,57.95);
			border.width;
			addChild(border);
			
			//event listener for serving
			
			
			//Start timer and set event listeners for collision checking.
			gameTimer = new Timer(30);
			collisionTimer = new Timer(30);
			delayTimer = new Timer(60,1);
			borderShrink = new Timer(30,53);//24,33, 40, 48,53
			borderGrow = new Timer(30, 53);//5, 8 ,
			
			gameTimer.start();
			collisionTimer.start();
			delayTimer.start();
			
			//timer event listeners
			collisionTimer.addEventListener(TimerEvent.TIMER, checkCollision);
			gameTimer.addEventListener(TimerEvent.TIMER, movePlayer);
			borderShrink.addEventListener(TimerEvent.TIMER, shrink);
			borderShrink.addEventListener(TimerEvent.TIMER_COMPLETE, goBack);
			borderGrow.addEventListener(TimerEvent.TIMER, grow);
			borderGrow.addEventListener(TimerEvent.TIMER, goBack);
			delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, start);
		
			//Text
			myFormat.font = "Arial";
			myFormat.size = 25;
			myFormat.color = 0xFFFFFF;
			
			playerLives.x = 25;
			playerLives.y = 20;
			playerLives.autoSize = "left";
			playerLives.defaultTextFormat = myFormat;
			playerLives.text = "Lives: " + pLives;
			addChild(playerLives);
			
			oppLives.x = 550;
			oppLives.y = 20;
			oppLives.autoSize = "left";
			oppLives.defaultTextFormat = myFormat;
			oppLives.text = "Opponent Lives: " + aLives;
			addChild(oppLives);
			
			levelDisplay.x = stage.width/2 - levelDisplay.width/2;
			levelDisplay.y = 20;
			levelDisplay.autoSize = "left";
			levelDisplay.defaultTextFormat = myFormat;
			levelDisplay.text = "Level: " + level;
			addChild(levelDisplay);
		}
		
		//GAME START//
		//START//
		/* a delay to prevent the intial stage button at the start from triggering the mouse click event for serving.
		*pre: the corresponding Timer must complete its full cycle.
		*post: an event listener is added to the mouse Click function
		*/
		function start(event:TimerEvent):void
		{
			stage.addEventListener(MouseEvent.CLICK, serve); 
		}	//end of start
		
		//SERVE//
		/* If the ball is in serving position the ball will start moving as soon as the player is over the ball and clicks the mosue
		*pre: serving must be true and the player's paddle must be touching the ball
		*post: movement of the border will start and the ball will start moving towards a direction based of paddle positioning.
		*/
		function serve(event:MouseEvent):void
		{
			//if it's the player's turn to serve and their paddle is over the ball when they click, the ball will start moving
			if(serving == true && (ball.hitTestObject(player)))
			{
				//Based off of the position of the ball and paddle, the ball velocity will change accordingly
				//left top
				if((ball.x + ball.width/2) < (player.x + player.width/2) && (ball.y + ball.height/2) < (player.y +player.height/2))
				{
					ball.xVel = -sVel;
					ball.yVel = -sVel;
				}
				//right bottom
				else if((ball.x + ball.width/2) > (player.x + player.width/2) && (ball.y + ball.height/2) > (player.y + player.height/2))
				{
					ball.xVel = sVel;
					ball.yVel = sVel;
				}
				//right top
				else if((ball.x + ball.width/2) > (player.x + player.width/2) && (ball.y + ball.height/2) < (player.y + player.height/2))
				{
					ball.xVel = sVel;
					ball.yVel = -sVel;
				}
				//left bottom
				else if((ball.x + ball.width/2) < (player.x + player.width/2) && (ball.y + ball.height/2) > (player.y + player.height/2))
				{
					ball.xVel = -sVel;
					ball.yVel = sVel;
				}
					
				ball.startMoving();
				borderShrink.start();
				serving = false;
				
				players.play();
			}
		}	//end of serve
		
		//NEXT LEVEL//
		/* If requirements are met to proceed to the next level then adjust the appropriate variables
		*pre: the opponent must miss the ball and for the main functionality of the function to run, their life counter must be 0
		*post: Adjust the speed of the opponent and increase the level and reset opponent lives back to 2
		*/
		function nextLevel():void
		{
			if(aLives == 0)
			{
				level ++;
				aLives = 2;
				aiSpeed +=1;
				
				levelDisplay.text = "Level: " + level;
				oppLives.text = "Opponent Lives: " + aLives;
			}
		}	//end of nextLevel
		
		//GAME OVER//
		/* Terminates gameplay and goes to game over screen if appropriate requirements are met
		*pre: the player's paddle must miss the ball and for full functionality of the function, player life counter must be 0.
		*post: Game is ended and program will go to the input highscore screen.
		*/
		function gameOver():void
		{
			if(pLives == 0)
			{
				gameTimer.stop();
				collisionTimer.stop();
				borderGrow.stop();
				borderShrink.stop();
				
				MovieClip(root).level = level;
				MovieClip(root).gotoAndStop("InputScreen");
			}
		}	//end of gameOver
		
		//MOVEMENT//
		//MOVE PLAYER
		/* This allows the player's paddle to move towards the position of the mouse and the ai to move towards the ball everytime the timer ticks
		*pre: the appropriate timer must be ticking.
		*post: player will be moved towards mouse position and ai paddle will move towards ball position.
		*/
		function movePlayer(event:TimerEvent):void
		{
			player.x = (mouseX - player.width/2);
			player.y = (mouseY - player.height/2);
			
			//move left
			if((ball.x + ball.width/2) < (ai.x + ai.width/2))
			{
				ai.x -= aiSpeed;
				//trace("left");
			}
			//move right
			else if((ball.x + ball.width/2) > (ai.x + ai.width/2))
			{
				ai.x +=aiSpeed;
			}
			
			//move up
			if((ball.y + ball.height/2) < (ai.y + ai.height/2))
			{
				ai.y -= aiSpeed;
			}
			//move down
			else if((ball.y + ball.height/2) > (ai.y +ai.height/2))
			{
				ai.y +=aiSpeed;
			}
		}
		
		//BORDER MOVEMENT//
		/* Shrinks the paddle to simulate the traversing of the ball down the screen.
		*pre: the appropriate timer must be ticking.
		*post: The border will shrink and adjust accordingly based off positioning and time.
		*/
		//Shrinks the border of the play field to determine when the ball should bounce and adjust balls size and place.
		function shrink(event:TimerEvent):void
		{
			border.x += borderXShrink;
			border.width -= borderWShrink;
			border.y += borderYShrink;
			border.height -= borderHShrink;
			
			ball.x += borderXShrink;
			ball.y += borderYShrink;
			ball.width -= 1;
			ball.height -= 1;
			
			scaleCount ++;
			
			//if scaleCount is = to any of the corresponding numbers, adjust the shrink scaling accordingly
			if(scaleCount == 48)
			{
				borderXShrink = 5.2;
				borderWShrink = 10.2;
				
				ball.speedDown();
			}
			else if(scaleCount == 39)
			{
				borderYShrink = 3.3;
				
				ball.speedDown();
			}
			else if(scaleCount == 23)
			{
				borderXShrink = 5;
				borderYShrink = 3.44;
				borderWShrink = 10;
				borderHShrink = 6.7;
				
				ball.speedDown();
			}
		}	//end of shrink
		
		//GOBACK//
		/* Depending on the whether the ball is at the front or back, the border & ball will be sent back if appropriate requirements are met.
		*pre: The appropriate timer must be complete its ticking cycle
		*post: If the proper requirements are met the ball and border will go towards the back/front of the screen.
		*/
		function goBack(event:TimerEvent):void
		{
			//GROW//
			//at the back
			//If scaleCount is 53 when this event is called resets the shrink timer and stops it and starts the Grow timer.
			if(scaleCount == 53)
			{
				borderShrink.reset();
				borderShrink.stop();
				
				//If the AI's paddle makes contact with the ball, the ball will bounc back
				if(ball.hitTestObject(ai))
				{
					borderGrow.start();
					
					//Based off of the position of the ball and paddle, the ball velocity will change accordingly
					//left top
					if((ball.x + ball.width/2) < (ai.x + ai.width/2) && (ball.y + ball.height/2) < (ai.y +ai.height/2))
					{
						ball.xVel = -sVel;
						ball.yVel = -sVel;
					}
					//right bottom
					else if((ball.x + ball.width/2) > (ai.x + ai.width/2) && (ball.y + ball.height/2) > (ai.y + ai.height/2))
					{
						ball.xVel = sVel;
						ball.yVel = sVel;
					}
					//right top
					else if((ball.x + ball.width/2) > (ai.x + ai.width/2) && (ball.y + ball.height/2) < (ai.y + ai.height/2))
					{
						ball.xVel = sVel;
						ball.yVel = -sVel;
					}
					//left bottom
					else if((ball.x + ball.width/2) < (ai.x + ai.width/2) && (ball.y + ball.height/2) > (ai.y + ai.height/2))
					{
						ball.xVel = -sVel;
						ball.yVel = sVel;
					}
					
					opponent.play();
				}
				//if the AI misses the ball, they will lose a life and the ball will reset its position and checks if
				//the player made it to the next level.
				else
				{
					reset();
					aLives --;
					oppLives.text = "Opponent Lives: " + aLives;
					nextLevel();
					
					miss.play();
				}
			}
			//SHRINK//
			//at the front
			//If scaleCount is 0 when this event is called, resets the grow timer and stops it and start the shrink timer
			//also readjust the x and y of the border to take into account for any inconsistancies getting back into place.
			else if (scaleCount == 0)
			{
				border.x = 29.45;
				border.y = 57.95;
				borderGrow.reset();
				borderGrow.stop();
				
				//if the players paddle is in contact with the ball, the ball will bounce.
				if(ball.hitTestObject(player))
				{
					borderShrink.start();
					
					//Based off of the position of the ball and paddle, the ball velocity will change accordingly
					//left top
					if((ball.x + ball.width/2) < (player.x + player.width/2) && (ball.y + ball.height/2) < (player.y +player.height/2))
					{
						ball.xVel = -sVel;
						ball.yVel = -sVel;
					}
					//right bottom
					else if((ball.x + ball.width/2) > (player.x + player.width/2) && (ball.y + ball.height/2) > (player.y + player.height/2))
					{
						ball.xVel = sVel;
						ball.yVel = sVel;
					}
					//right top
					else if((ball.x + ball.width/2) > (player.x + player.width/2) && (ball.y + ball.height/2) < (player.y + player.height/2))
					{
						ball.xVel = sVel;
						ball.yVel = -sVel;
					}
					//left bottom
					else if((ball.x + ball.width/2) < (player.x + player.width/2) && (ball.y + ball.height/2) > (player.y + player.height/2))
					{
						ball.xVel = -sVel;
						ball.yVel = sVel;
					}
					
					players.play();
				}
				//Resets ball position and player loses a life and checks if game over is required.
				else
				{
					reset();
					pLives --;
					playerLives.text = "Lives: " + pLives;
					gameOver();
					
					miss.play();
				}
			}
		}	//end of goBack
		
		//GROW//
		/* Grows the paddle to simulate the traversing of the ball up the screen.
		*pre: the appropriate timer must be ticking.
		*post: The border will grow and adjust accordingly based off positioning and time.
		*/
		function grow(event:TimerEvent):void
		{
			border.x -= borderXShrink;
			border.y -= borderYShrink;
			border.width += borderWShrink;
			border.height += borderHShrink;
			
			ball.x -= borderXShrink;
			ball.y -= borderYShrink;
			ball.width += 1;
			ball.height += 1;
			
			scaleCount --;
			
			//if the scaleCount is equal to any of these numbers, adjust growth rate accordingly
			if(scaleCount == 48)
			{
				ball.speedUp();
					
				borderXShrink = 5;
				borderWShrink = 10;
			}
			else if(scaleCount == 39)
			{
				ball.speedUp();
				
				borderXShrink = 5;
				borderYShrink = 3.44;
				borderWShrink = 10;
				borderHShrink = 6.7;
			}
			else if(scaleCount == 23)
			{
				ball.speedUp();
					
				borderXShrink = 5.2;
				borderYShrink = 3.48;
				borderWShrink = 10.4;
				borderHShrink = 6.93;
			}
		}	//end of grow
		
		//STAGE RESET//
		function reset():void
		{
			ball.stopMoving();
			
			ball.x = stage.width/2;
			ball.y = stage.height/2;
			ball.width = 60;
			ball.height = 61;
			
			border.x = 29.45;
			border.y = 57.95;
			border.width = 721;
			border.height = 481;
		
			ball.xVel = sVel;
			ball.yVel = sVel;
			
			borderShrink.reset();
			borderGrow.reset();
			scaleCount = 0;
			
			serving = true;
			//delayTimer.start();
			
		}	//end of reset
		
		//CHECKCOLLISION//
		/*Checks to see if any objects are colliding at certain positioning and takes appropriate action
		*pre: The appropriate timer must be ticking and the specific requirements below must be met if any action should be taken.
		*post: adjust the position and velocity of objects depending on the event.
		*/
		function checkCollision(event:TimerEvent):void
		{
			//Paddle/Wall
			//left
			if(player.x < 35)
			{
				player.x = 35;
			}
			//right
			if(player.x + player.width > 778 - 33)
			{
				player.x = 778 - player.width - 33;
			}
			//top
			if(player.y < 60)
			{
				player.y = 60;
			}
			//bottom
			if(player.y > (600 - player.height - 65))
			{
				player.y = 600 - player.height - 65;
			}
			
			//Ball/Border
			//left
			if(ball.x < border.x)
			{
				ball.x = border.x;
				ball.xBounce();
				wall.play();
			}
			//right
			if(ball.x > ((border.x + border.width) - ball.width))
			{
				ball.x = (border.x + border.width) - ball.width;
				ball.xBounce();
				wall.play();
			}
			//top
			if(ball.y < border.y)
			{
				ball.y = border.y;
				ball.yBounce();
				wall.play();
			}
			//bottom
			if(ball.y > (border.y + border.height - ball.height))
			{
				ball.y = (border.y + border.height) - ball.height;
				ball.yBounce();
				wall.play();
			}
			
			//Ai/border
			//left
			if(ai.x < 303)
			{
				ai.x = 303;
			}
			//right
			if((ai.x + ai.width) > 479)
			{
				ai.x = 479-ai.width;
			}
			//top
			if((ai.y < 240))
			{
				ai.y = 240;
			}
			//bottom
			if((ai.y + ai.height) > 357)
			{
				ai.y = 357-ai.height;
			}
		}	//end of checkCollision
		
	}	///end of class
	
}	//end of package
