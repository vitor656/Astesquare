package;

import flixel.util.FlxAxes;
import flixel.text.FlxBitmapText;
import flixel.addons.effects.FlxTrail;
import flixel.math.FlxAngle;
import flixel.math.FlxVelocity;
import flixel.math.FlxRandom;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxState;

class PlayState extends FlxState
{

	public var player : Player;
	public var enemies : FlxTypedGroup<Enemy>;
	public var scoreText : FlxBitmapText;
	public var restartText : FlxBitmapText;

	var random : FlxRandom;

	override public function create():Void
	{
		super.create();

		Reg.PS = this;
		random = new FlxRandom();

		setupGame();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if(FlxG.keys.justPressed.F) FlxG.fullscreen = !FlxG.fullscreen;

		if(!player.alive) {
			//restartText.visible = true;

			if(FlxG.mouse.justPressed) {
				FlxG.resetState();
			}
		}

		collisions();

		scoreText.text = Std.string(Reg.score);
	}

	function setupGame() : Void
	{
		Reg.score = 0;

		player = new Player();
		enemies = new FlxTypedGroup<Enemy>(100);

		scoreText = new FlxBitmapText();
		scoreText.screenCenter(FlxAxes.X);
		scoreText.y += 16;
		scoreText.scale.set(4, 4);

		restartText = new FlxBitmapText();
		restartText.text = "Click to play again";
		restartText.scale.set(2, 2);
		restartText.screenCenter();
		restartText.visible = false;

		add(enemies);
		add(scoreText);
		add(restartText);

		new FlxTimer().start(1, function(timer) { 
			createEnemy( random.int(0, FlxG.width), random.int(0, FlxG.height) ); 
		}, 0);
	}

	public function setupGameOver() : Void
	{
		FlxSpriteUtil.flicker(restartText, 0, 0.2);
	}

	function createEnemy(x : Int, y : Int) : Void
	{
		if(player.alive)
			enemies.add(new Enemy(x, y));
	}

	function collisions() : Void
	{
		FlxG.overlap(player, enemies, function(_player, _enemy){
			_player.collideWithEnemy();
			_enemy.collideWithPlayer(_player);
		});
	}

}
