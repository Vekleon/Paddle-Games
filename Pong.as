/*
	File Name: Pong.as
	Programmer: Thomas Leung
	Date: 5/6/16
	Description: A recreation of the game pong amatuerly reprogrammed.
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
	import flash.media.SoundChannel;
	
	public class Pong extends Sprite{
		
		//object and variable declaration
		public var playerOne:Paddle;
		public var playerTwo:Paddle;
		public var ball:Ball;
		
		//SOUNDS
		public var players:PlayerBounce = new PlayerBounce();
		public var balls:BallDrop = new BallDrop();
		public var wall:WallSound = new WallSound();
		
		//TIMERS
		var gameTimer:Timer;
		var ballDelay:Timer;
		
		
		//POINTS
		var playerOnePoints:int = 0;
		var playerTwoPoints:int = 0;
		
		//TEXT
		var myFormat:TextFormat = new TextFormat;
		var playerOneScreenPoints:TextField = new TextField;
		var playerTwoScreenPoints:TextField = new TextField;
		var winnerName:String;
		
		//Constructor fucntion
		//Sets the game elements in place. This game spawns to paddles and a ball which the paddles
		//will compete against each other to be the first to score 11 points or 2 higher than the opponent at game point.
		public function Pong() 
		{
			//instantiate a new paddle obejct for PLAYERONE
			playerOne = new Paddle(330,581,37,39);
			addChild(playerOne);
			stage.addEventListener(Event.ENTER_FRAME, playerOne.moveCheck);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, playerOne.movePaddle);
			stage.addEventListener(KeyboardEvent.KEY_UP, playerOne.stopMove);
			
			//instantiate a new paddle object for PLAYERTWO
			playerTwo = new Paddle(505,20,65,68);
			playerTwo.rotation = 180;
			addChild(playerTwo);
			stage.addEventListener(Event.ENTER_FRAME, playerTwo.moveCheck);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, playerTwo.movePaddle);
			stage.addEventListener(KeyboardEvent.KEY_UP, playerTwo.stopMove);
			
			//instantiate a new ball object for play
			ball = new Ball(400,291,10,10);
			addChild(ball);
			ballDelay = new Timer(600,1);
			ballDelay.start();
			ballDelay.addEventListener(TimerEvent.TIMER_COMPLETE, ballReset);
			
			//Instantiate gameTimer which will run through the game to determine collison
			gameTimer = new Timer(30);
			gameTimer.start();
			gameTimer.addEventListener(TimerEvent.TIMER, checkCollision);
			
			//set formatting for program text fields
			myFormat.font = "Arial";
			myFormat.size = 80;
			myFormat.bold = true;
			myFormat.color=0x000000;
			
			//Display the points of playerOne and set format
			playerOneScreenPoints.x = 5;
			playerOneScreenPoints.y = 301;
			playerOneScreenPoints.autoSize = "left";
			playerOneScreenPoints.defaultTextFormat=myFormat;
			playerOneScreenPoints.text = String(playerOnePoints);
			addChild(playerOneScreenPoints);
			
			//Display and set the format of the poitns of playerTwo
			playerTwoScreenPoints.x = 5;
			playerTwoScreenPoints.y = 201;
			playerTwoScreenPoints.autoSize = "left";
			playerTwoScreenPoints.defaultTextFormat=myFormat;
			playerTwoScreenPoints.text = String(playerTwoPoints);
			addChild(playerTwoScreenPoints);
			
		}	//end of constructor function
		
		//Starts the ball after a slight delay
		//pre: ball must've hit the top or bottom of screen
		function ballReset(event:TimerEvent):void
		{
			ball.startMoving();
			wall.play();
		}
		
		/*Checks to see if a player has won and terminates the game if that's is the case
		*pre: a player've must've scored for this function to go off
		*post: if a player wins goes to another function will takes care of termination
		*/
		//Checks the score to see if there is a potential winner.
		function checkWin():void
		{
			var winner:int;
			//if playerOne has 10 or more points its checks if playerTwo does as well
			if(playerOnePoints >= 10)
			{
				//if playerTwo has greater than or equal 10 points it checks if playerOne has a two point lead
				if(playerTwoPoints >= 10)
				{
					winner = playerOnePoints - playerTwoPoints;
					//if playerOne has a two point lead they
					if(winner ==2)
					{
						winnerName = "Player One";
						win();
					}
				}
				//if playerOne has 11 points they win
				else if(playerOnePoints == 11)
				{
					winnerName = "Player One";
					win();
				}
			}	//End of playerOne check
			
			//if playerTwo has 10 or more points it checks if playerOne does as well
			if(playerTwoPoints >= 11)
			{
				//if playerOne has 10 or more points it checks if playerTwo has a two point lead
				if(playerOnePoints >= 10)
				{
					winner = playerTwoPoints - playerOnePoints;
					//if playerTwo has a two point lead they win
					if(winner ==2)
					{
						winnerName = "Player Two";
						win();
					}
				}
				//if playerTwo has 11 Points they win.
				else if(playerTwoPoints == 11)
				{
					winnerName = "Player Two";
					win();
				}
			}	//End of playerTwo check
			
		}	//End of checkWin
		
		/*Terminates game
		*pre: requirements for a winning player must've been met
		*post: removes all event listeners and gameplay functionality and goes to game over screen.
		*/
		//When someone wins it removes all active event listeners and stops timers.
		function win():void
		{
			gameTimer.stop();
			gameTimer.removeEventListener(TimerEvent.TIMER, checkCollision);
					
			ball.stopMoving();
			stage.removeEventListener(Event.ENTER_FRAME, playerOne.moveCheck);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, playerOne.movePaddle);
			stage.removeEventListener(KeyboardEvent.KEY_UP, playerOne.stopMove);
					
			stage.removeEventListener(Event.ENTER_FRAME, playerTwo.moveCheck);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, playerTwo.movePaddle);
			stage.removeEventListener(KeyboardEvent.KEY_UP, playerTwo.stopMove);
			
			MovieClip(root).winnerName = winnerName;
			trace(winnerName);
			MovieClip(root).gotoAndStop("GameOver");
		}	//end of win
		
		//Collision detection//
		/*Checks to see if any objects are colliding at certain positioning and takes appropriate action
		*pre: The appropriate timer must be ticking and the specific requirements below must be met if any action should be taken.
		*post: adjust the position and velocity of objects depending on the event.
		*/
		function checkCollision(event:TimerEvent):void
		{
			//Check for wall paddle collisions and prevents paddle from going off stage
			if(playerOne.x < 0)
			{
				playerOne.x = 0;
			}
			
			if(playerOne.x > 618)
			{
				playerOne.x = 618;
			}	
			
			if(playerTwo.x < playerTwo.width)
			{
				playerTwo.x = playerTwo.width;
			}
			
			if(playerTwo.x > 774)
			{
				playerTwo.x = 774;
			}//end of paddle/ball collision
			
			//Check Ball wall collision
			if(ball.x < 0)
			{
				ball.xBounce();
				ball.x = 0;
				wall.play();
			}
			
			if(ball.x > 759)
			{
				ball.xBounce();
				ball.x = 759;
				wall.play();
			}
			
			//Check Ball with collision with top or bottom of the stage.
			//If the ball hits the top of the stage reset ball position and set ball yVelocity to go down
			//Puts a delay on the ball before it starts and gives playerOne a point.
			if(ball.y < 0)
			{
				ball.x = 400;
				ball.y = 291;
				ball.yVel = -10;
				ball.xVel = Math.random();
				ball.stopMoving();
				ballDelay.start();
				
				playerOnePoints ++;

				playerOneScreenPoints.text = String(playerOnePoints);
				checkWin();
				balls.play();
			}
			
			//If the ball hits the top of the stage reset ball position and set ball yVelocity to go up
			//Puts a delay on the ball before it starts and gives playerTwo a point.
			if(ball.y > 600)
			{
				ball.x = 400;
				ball.y = 291;
				ball.yVel = 10;
				ball.xVel = (Math.random()+Math.random());
				ball.stopMoving();
				ballDelay.start();
				
				playerTwoPoints ++;
				
				playerTwoScreenPoints.text = String(playerTwoPoints);
				checkWin();
				balls.play();
			}	//end of ball/wall
			
			//Paddle ball collision
			if(ball.hitTestObject(playerOne))
			{
				ball.yBounce();
				ball.xVel = (((ball.x + ball.width) - (playerOne.x) - 100) / 3);
				 players.play();
			}
			
			if(ball.hitTestObject(playerTwo))
			{
				ball.yBounce();
				ball.xVel = (((ball.x + ball.width) - (playerTwo.x) + 100) / 3);
				players.play();
			}
			
		}	//End of checkCollision
		
	}	//End of class
	
}	//end of package
