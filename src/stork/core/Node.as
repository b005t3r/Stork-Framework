/**
 * User: booster
 * Date: 24/01/14
 * Time: 9:55
 */
package stork.core {
import flash.utils.getQualifiedClassName;

import stork.core.reference.Reference;
import stork.core.reference.ReferenceHandler;
import stork.core.reference.ReferenceUtil;
import stork.event.EventDispatcher;

public class Node extends EventDispatcher {
    private var _name:String;
    private var _parentNode:ContainerNode;

    stork_internal var _references:Vector.<Reference>               = null;
    stork_internal var _referenceHandlers:Vector.<ReferenceHandler> = null;

    stork_internal var beingAdded:Boolean       = false;
    stork_internal var beingRemoved:Boolean     = false;

    public function Node(name:String = "Node") {
        _name = name;

        ReferenceUtil.stork_internal::injectReferences(this);
    }

    public function get name():String { return _name; }

    public function get parentNode():ContainerNode { return _parentNode; }
    public function get sceneNode():SceneNode {
        var node:Node = this;

        while (node != null && node is SceneNode == false)
            node = node._parentNode;

        return node as SceneNode;
    }

    public function toString():String {
        return "[" + getQualifiedClassName(this).split("::").pop() + " name=\"" + _name + "]";
    }

    public function removeFromParent():void {
        if(_parentNode == null) return;

        _parentNode.removeNode(this);
    }

    internal function setParentNode(value:ContainerNode):void {
        // check for a recursion
        var ancestor:ContainerNode = value;
        while (ancestor != this && ancestor != null)
            ancestor = ancestor._parentNode;

        if (ancestor == this)
            throw new ArgumentError("a node cannot be added as a child to itself or one of its children (or children's children, etc.)");

        _parentNode = value;
    }
}
}
