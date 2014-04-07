/**
 * User: booster
 * Date: 05/03/14
 * Time: 13:35
 */
package stork.game {
import stork.core.ContainerNode;
import stork.event.Event;
import stork.event.game.GameLoopEvent;
import stork.event.SceneStepEvent;

public class GameLoopNode extends ContainerNode {
    private var _preLoopEvent:GameLoopEvent = new GameLoopEvent(GameLoopEvent.PRE_LOOP);
    private var _postLoopEvent:GameLoopEvent = new GameLoopEvent(GameLoopEvent.POST_LOOP);

    protected var _timeScale:Number   = 1.0;
    protected var _paused:Boolean     = false;

    public function GameLoopNode(name:String = "GameLoopNode") {
        super(name);

        addEventListener(Event.ADDED_TO_SCENE, onAddedToScene);
        addEventListener(Event.REMOVED_FROM_SCENE, onRemovedFromScene);
    }

    /** Ratio used to scale each time interval passed to children (may be negative). @default 1.0 */
    public function set timeScale(value:Number):void { _timeScale = value; }
    public function get timeScale():Number { return _timeScale; }

    /** Is this Juggler currently paused or not. @default false */
    public function set paused(value:Boolean):void { _paused = value; }
    public function get paused():Boolean { return _paused; }

    protected function onAddedToScene(event:Event):void { sceneNode.addEventListener(SceneStepEvent.STEP, onStep); }
    protected function onRemovedFromScene(event:Event):void { sceneNode.removeEventListener(SceneStepEvent.STEP, onStep); }

    protected function onStep(event:SceneStepEvent):void {
        if(_paused) return;

        dispatchEvent(_preLoopEvent.reset());

        var scaledDt:Number = event.dt / _timeScale;

        var count:int = nodeCount;
        for(var i:int = 0; i < count; ++i) {
            var action:GameActionNode = getNodeAt(i) as GameActionNode;

            if(action == null)
                continue;

            action.advance(scaledDt);

            // TODO: this will still crash/malfunction when a action removes itself on advance() call
            if(action.autoReset && (action.finished || action.canceled)) {
                action.reset(); // removes from game loop
                --i;            // adjust next index & count after removing action
                --count;
            }
        }

        dispatchEvent(_postLoopEvent.reset());
    }
}
}
