/**
 * User: booster
 * Date: 05/03/14
 * Time: 13:35
 */
package stork.game {
import medkit.collection.ArrayList;
import medkit.collection.CollectionUtil;
import medkit.collection.List;
import medkit.object.Comparator;

import stork.core.ContainerNode;
import stork.core.Node;
import stork.event.Event;
import stork.event.SceneStepEvent;
import stork.event.game.GameLoopEvent;

public class GameLoopNode extends ContainerNode {
    private var _preLoopEvent:GameLoopEvent = new GameLoopEvent(GameLoopEvent.PRE_LOOP);
    private var _postLoopEvent:GameLoopEvent = new GameLoopEvent(GameLoopEvent.POST_LOOP);

    protected var _timeScale:Number     = 1.0;
    protected var _paused:Boolean       = false;

    protected var _sortedNodes:List     = new ArrayList();
    protected var _cmp:Comparator       = new GameActionPriorityComparator();
    protected var _needsSorting:Boolean = true;

    public function GameLoopNode(name:String = "GameLoop") {
        super(name);

        addEventListener(Event.ADDED_TO_SCENE, onAddedToScene);
        addEventListener(Event.REMOVED_FROM_SCENE, onRemovedFromScene);
        addEventListener(Event.ADDED_TO_PARENT, onAddedToParent);
        addEventListener(Event.REMOVED_FROM_PARENT, onRemovedFromParent);
    }

    /** Ratio used to scale each time interval passed to children (may be negative). @default 1.0 */
    public function set timeScale(value:Number):void { _timeScale = value; }
    public function get timeScale():Number { return _timeScale; }

    /** Is this Juggler currently paused or not. @default false */
    public function set paused(value:Boolean):void { _paused = value; }
    public function get paused():Boolean { return _paused; }

    protected function onAddedToScene(event:Event):void { sceneNode.addEventListener(SceneStepEvent.STEP, onStep); }
    protected function onRemovedFromScene(event:Event):void { sceneNode.removeEventListener(SceneStepEvent.STEP, onStep); }

    protected function onAddedToParent(event:Event):void {
        var node:Node = event.target as Node;

        if(node.parentNode != this) return;

        _needsSorting = true;
    }

    protected function onRemovedFromParent(event:Event):void {
        var node:Node = event.target as Node;

        if(node.parentNode != this) return;

        _needsSorting = true;
    }

    protected function onStep(event:SceneStepEvent):void {
        if(_needsSorting)
            sortNodes();

        if(_paused) return;

        dispatchEvent(_preLoopEvent.reset());

        var scaledDt:Number = event.dt / _timeScale;

        var count:int = _sortedNodes.size();
        for(var i:int = 0; i < count; ++i) {
            var action:GameActionNode = _sortedNodes.get(i) as GameActionNode;

            if(action == null)
                continue;

            action.advance(scaledDt);

            if(action.autoReset && (action.finished || action.canceled)) {
                action.reset(); // removes from game loop
            }
        }

        dispatchEvent(_postLoopEvent.reset());
    }

    private function sortNodes():void {
        _needsSorting = false;

        _sortedNodes.clear();

        var count:int = nodeCount;
        for(var i:int = 0; i < count; ++i) {
            var node:GameActionNode = getNodeAt(i) as GameActionNode;

            if(node == null)
                continue;

            var index:int = CollectionUtil.binarySearch(_sortedNodes, node, _cmp);

            // element not found, need to calculate insertion index
            if(index < 0)
                index = -index - 1;

            _sortedNodes.addAt(index, node);
        }
    }
}
}

import medkit.object.Comparator;
import medkit.object.Equalable;

import stork.game.GameActionNode;

class GameActionPriorityComparator implements Comparator {
    public function compare(o1:*, o2:*):int {
        var node1:GameActionNode = o1 as GameActionNode;
        var node2:GameActionNode = o2 as GameActionNode;

        return node1.priority - node2.priority;
    }

    // stubs
    public function equals(object:Equalable):Boolean { return false; }
    public function hashCode():int { return 0; }
}