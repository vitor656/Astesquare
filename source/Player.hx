package;

import flixel.effects.particles.FlxEmitter;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.addons.effects.FlxTrail;
import flixel.FlxSprite;

class Player extends FlxSprite
{

    var _spinMultiplier : Float = 200;
    var _lerpFactor : Float = 0.05;
    var _trail : FlxTrail;
    var _nextPosition : FlxPoint;

    var _explosion : FlxEmitter;

    public function new()
    {
        super();

        makeGraphic(8, 8, FlxColor.WHITE);
		screenCenter();
        _trail = new FlxTrail(this, null, 30, 3, 0.4, 0.05);
        _nextPosition = new FlxPoint(FlxG.width / 2, FlxG.height / 2);

        Reg.PS.add(this);
        Reg.PS.add(_trail);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        inputs();
        movement();

    }

    function inputs() : Void
    {
        if(FlxG.mouse.justPressed){
            _nextPosition = FlxG.mouse.getPosition();
        }
    }

    function movement() : Void
    {

        if(FlxMath.distanceToPoint(this, _nextPosition) > 10) {
            angle += FlxG.elapsed * _spinMultiplier * 2;
        } else {
            angle += FlxG.elapsed * _spinMultiplier;
        }

        //angle += FlxG.elapsed * _spinMultiplier;

		x = FlxMath.lerp(x, _nextPosition.x, _lerpFactor);
		y = FlxMath.lerp(y, _nextPosition.y, _lerpFactor);

    }

    function collideWithEnemy() : Void
    {
        
    }

    public function die() : Void
    {
        explode();
        _trail.kill();
        
        Reg.PS.setupGameOver();

        kill();
    }
    
    function explode() : Void
    {
        _explosion = new FlxEmitter(x, y);
        _explosion.makeParticles(1, 1, FlxColor.WHITE, 100);

        Reg.PS.add(_explosion);
        _explosion.start();
    }
}