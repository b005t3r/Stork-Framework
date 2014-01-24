/**
 * User: booster
 * Date: 24/01/14
 * Time: 9:57
 */
package stork.core {
import stork.event.Event;

public class ContainerNode extends Node {
    private static var _broadcastListeners:Vector.<Node> = new <Node>[];

    private var _addedToStageEvent:Event        = new Event(Event.ADDED_TO_STAGE);
    private var _addedToParentEvent:Event       = new Event(Event.ADDED_TO_PARENT, true);
    private var _removedFromStageEvent:Event    = new Event(Event.REMOVED_FROM_STAGE);
    private var _removedFromParentEvent:Event   = new Event(Event.REMOVED_FROM_PARENT, true);

    private var _nodes:Vector.<Node>            = new <Node>[];

    public function ContainerNode(name:String = "ContainerNode") {
        super(name);
    }

    public function get nodeCount():int { return _nodes.length; }

    public function addNode(node:Node):void {
        addNodeAt(node, nodeCount);
    }
    
    public function addNodeAt(node:Node, index:int):void {
        var count:int = _nodes.length;

        if(index >= 0 && index <= count) {
            if(node.parentNode == this) {
                setNodeIndex(node, index); // avoids dispatching events
            }
            else {
                node.removeFromParent();

                // 'splice' creates a temporary object, so we avoid it if it's not necessary
                if(index == count)  _nodes[count] = node;
                else                _nodes.splice(index, 0, node);

                node.setParentNode(this);
                node.dispatchEvent(_addedToParentEvent);

                if(sceneNode) {
                    var container:ContainerNode = node as ContainerNode;

                    if(container != null)   container.broadcastEvent(_addedToStageEvent);
                    else                    node.dispatchEvent(_addedToStageEvent);
                }
            }
        }
        else {
            throw new RangeError("Invalid node index");
        }
    }

    public function removeNode(node:Node):void {
        var nodeIndex:int = getNodeIndex(node);

        if (nodeIndex != -1)
            removeNodeAt(nodeIndex);
    }

    public function removeNodeAt(index:int):void {
        if(index >= 0 && index < nodeCount) {
            var child:Node = _nodes[index];
            child.dispatchEvent(_removedFromParentEvent);

            if(sceneNode) {
                var container:ContainerNode = child as ContainerNode;

                if(container != null)  container.broadcastEvent(_removedFromStageEvent);
                else                    child.dispatchEvent(_removedFromStageEvent);
            }

            child.setParentNode(null);
            index = _nodes.indexOf(child); // index might have changed by event handler

            if(index >= 0)
                _nodes.splice(index, 1);
        }
        else {
            throw new RangeError("Invalid child index");
        }
    }

    public function removeNodes(beginIndex:int = 0, endIndex:int = -1):void {
        if(endIndex < 0 || endIndex >= nodeCount)
            endIndex = nodeCount - 1;

        for(var i:int = beginIndex; i <= endIndex; ++i)
            removeNodeAt(beginIndex);
    }

    public function getNodeIndex(node:Node):int { return _nodes.indexOf(node); }
    public function setNodeIndex(node:Node, index:int):void {
        var oldIndex:int = getNodeIndex(node);

        if (oldIndex == index) return;
        if (oldIndex == -1) throw new ArgumentError("Not a child of this container");

        _nodes.splice(oldIndex, 1);
        _nodes.splice(index, 0, node);
    }

    public function swapNodes(nodeA:Node, nodeB:Node):void {
        var indexA:int = getNodeIndex(nodeA);
        var indexB:int = getNodeIndex(nodeB);

        if (indexA == -1 || indexB == -1) throw new ArgumentError("Not a child of this container");

        swapNodesAt(indexA, indexB);
    }

    public function swapNodesAt(indexA:int, indexB:int):void {
        var child1:Node = getNodeAt(indexA);
        var child2:Node = getNodeAt(indexB);

        _nodes[indexA] = child2;
        _nodes[indexB] = child1;
    }

    public function getNodeAt(index:int):Node { return _nodes[index]; }

    public function getNodeByName(name:String):Node {
        var count:int = _nodes.length;
        for(var i:int = 0; i < count; ++i)
            if(_nodes[i].name == name)
                return _nodes[i];

        return null;
    }

    public function getNodeByClass(nodeClass:Class):Node {
        var count:int = _nodes.length;
        for(var i:int = 0; i < count; ++i)
            if(_nodes[i] is nodeClass)
                return _nodes[i];

        return null;
    }

    public function getNodesByClass(nodeClass:Class, nodes:Vector.<Node> = null):Vector.<Node> {
        if(nodes == null) nodes = new <Node>[];

        var count:int = _nodes.length;
        for(var i:int = 0; i < count; ++i)
            if(_nodes[i] is nodeClass)
                nodes[nodes.length] = _nodes[i];

        return nodes;
    }

    /** Dispatches an event with the given parameters on all children (recursively). */
    public function broadcastEvent(event:Event):void {
        if(event.bubbles)
            throw new ArgumentError("Broadcast of bubbling events is prohibited");

        // The event listeners might modify the node tree, which could make the loop crash.
        // Thus, we collect them in a list and iterate over that list instead.
        // And since another listener could call this method internally, we have to take
        // care that the static helper vector does not get corrupted.

        var fromIndex:int = _broadcastListeners.length;
        getChildEventListeners(this, event.type, _broadcastListeners);
        var toIndex:int = _broadcastListeners.length;

        for(var i:int = fromIndex; i < toIndex; ++i)
            _broadcastListeners[i].dispatchEvent(event);

        _broadcastListeners.length = fromIndex;
    }

    internal function getChildEventListeners(object:Node, eventType:String, listeners:Vector.<Node>):void {
        var container:ContainerNode = object as ContainerNode;

        if(object.hasEventListener(eventType))
            listeners[listeners.length] = object; // avoiding 'push'

        if(container) {
            var children:Vector.<Node> = container._nodes;
            var numChildren:int = children.length;

            for(var i:int = 0; i < numChildren; ++i)
                getChildEventListeners(children[i], eventType, listeners);
        }
    }
}
}
