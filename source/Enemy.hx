package;

import flixel.util.FlxSpriteUtil;
import flixel.effects.particles.FlxEmitter;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.addons.effects.FlxTrail;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.FlxSprite;

enum EnemyState {
    IDLE;
    WAITING;
    CHASE;
}

class Enemy extends FlxSprite
{

    var _speed : Float;
    var _multiplierFactor : Float;
    var _idleSpeedSet : Bool;
    var _idleFlickering : Bool;
    var _trail : FlxTrail;
    var _spinSpeed : Float;

    var _explosion : FlxEmitter;
    
    var _currentState : EnemyState;
    var _statesTimer : FlxTimer;

    public function new(x : Int, y : Int, width : Int = 8, height : Int = 8)
    {
        super(x, y);

        _speed = 20;
        _spinSpeed = 200;
        _multiplierFactor = 4;

		makeGraphic(width, height, FlxColor.RED);
		velocity.set(getVelocityToPlayer().x, getVelocityToPlayer().y);
        _idleSpeedSet = true;

        _trail = new FlxTrail(this, null, 30, 3, 0.5, 0.05);
        Reg.PS.add(_trail);

        _currentState =  EnemyState.IDLE;
        _statesTimer = new FlxTimer();
        _statesTimer.start(3, function(timer) {
            changeStates();
        }, 0);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        switch (_currentState){
            case EnemyState.IDLE:
                idleState();
            case EnemyState.WAITING:
                waitingState();
            case EnemyState.CHASE:
                chasingState();
        }
    }

    function changeStates() : Void
    {
        if(_currentState == EnemyState.IDLE){
            _currentState = EnemyState.WAITING;
            _idleSpeedSet = false;
            _idleFlickering = false;
        } else if (_currentState == EnemyState.WAITING){
            _currentState = EnemyState.CHASE;
        } else {
            _currentState = EnemyState.IDLE;
        }
    }

    function idleState() : Void
    {
        angle += FlxG.elapsed * _spinSpeed;
        if(!_idleSpeedSet) {
            var vel : FlxPoint = getVelocityToPlayer();
            velocity.set(vel.x, vel.y);

            _idleSpeedSet = true;
        }

        if (!_idleFlickering) {
            FlxSpriteUtil.flicker(this, 0, 0.5);
            _idleFlickering = true;
        }
    }

    function waitingState() : Void
    {
        angle += FlxG.elapsed * _spinSpeed * _multiplierFactor;
        velocity.set(0, 0);

        FlxSpriteUtil.stopFlickering(this);
    }

    function chasingState() : Void
    {
        angle += FlxG.elapsed * _spinSpeed * _multiplierFactor;
        
        var vel : FlxPoint = getVelocityToPlayer();
        velocity.set(vel.x * _multiplierFactor, vel.y * _multiplierFactor);
    }

    function getVelocityToPlayer() : FlxPoint
    {
        return new FlxPoint(
            _speed * FlxMath.fastCos(FlxAngle.angleBetween(this, Reg.PS.player)), 
            _speed * FlxMath.fastSin(FlxAngle.angleBetween(this, Reg.PS.player))
        );
    }

    function collideWithPlayer(player : Player) : Void
    {
        if(_currentState == EnemyState.IDLE) {
            die();
            Reg.score++;
        } else {
            player.die();
        }
    }

    function createExplosion() : Void
    {
        _explosion = new FlxEmitter(x, y);
        _explosion.makeParticles(2, 2, FlxColor.RED, 20);
        Reg.PS.add(_explosion);

        _explosion.start();
    }

    function die() : Void
    {
        createExplosion();
        spawnSmallerEnemies();
        _trail.kill();
        kill();
    }

    function spawnSmallerEnemies() : Void
    {
        var enemy_1 : Enemy = new Enemy(Std.int(x), Std.int(y), Std.int(width / 2), Std.int(height / 2));
        var enemy_2 : Enemy = new Enemy(Std.int(x), Std.int(y), Std.int(width / 2), Std.int(height / 2));
        Reg.PS.add(enemy_1);
        Reg.PS.add(enemy_2);
    }
}