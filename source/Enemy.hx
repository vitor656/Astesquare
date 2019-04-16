package;

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
    var _trail : FlxTrail;
    var _spinSpeed : Float;

    var _explosion : FlxEmitter;
    
    var _currentState : EnemyState;
    var _statesTimer : FlxTimer;

    public function new(x : Int, y : Int)
    {
        super(x, y);

        _speed = 20;
        _spinSpeed = 200;
        _multiplierFactor = 4;
        

		makeGraphic(8, 8, FlxColor.RED);
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
    }

    function waitingState() : Void
    {
        angle += FlxG.elapsed * _spinSpeed * _multiplierFactor;
        velocity.set(0, 0);
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
        _trail.kill();
        kill();
    }
}