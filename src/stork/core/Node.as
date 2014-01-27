/**
 * User: booster
 * Date: 24/01/14
 * Time: 9:55
 */
package stork.core {
import stork.event.EventDispatcher;

public class Node extends EventDispatcher {
    private var _name:String;
    private var _parentNode:ContainerNode;

    public function Node(name:String = "Node") {
        _name = name;
    }

    public function get name():String { return _name; }
    public function set name(value:String):void { _name = value; }

    public function get parentNode():ContainerNode { return _parentNode; }
    public function get sceneNode():SceneNode {
        var node:Node = this;

        while (node != null && node is SceneNode == false)
            node = node._parentNode;

        return node as SceneNode;
    }

    public function removeFromParent():void {
        if(_parentNode == null) return;

        _parentNode.removeNode(this);
    }

    internal function setParentNode(value:ContainerNode):void {
        var prevParent:Node     = _parentNode;
        var prevScene:SceneNode = sceneNode;
        var currParent:Node     = value;
        var currScene:SceneNode = value != null ? value.sceneNode : null;

        // check for a recursion
        var ancestor:ContainerNode = value;
        while (ancestor != this && ancestor != null)
            ancestor = ancestor._parentNode;

        if (ancestor == this)
            throw new ArgumentError("a node cannot be added as a child to itself or one of its children (or children's children, etc.)");

        if(prevParent != currParent && prevParent != null)
            onRemovedFromParent(prevParent);

        if(prevScene != currScene && prevScene != null)
            onRemovedFromScene(prevScene);

        _parentNode = value;

        if(prevParent != currParent && currParent != null)
            onAddedToParent(currParent);

        if(prevScene != currScene && currScene != null)
            onAddedToScene(currScene);
    }

    protected function onAddedToScene(scene:SceneNode):void {
    }

    protected function onAddedToParent(parent:Node):void {
    }

    protected function onRemovedFromScene(scene:SceneNode):void {
    }

    protected function onRemovedFromParent(parent:Node):void {
    }
}
}
