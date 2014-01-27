/**
 * User: booster
 * Date: 24/01/14
 * Time: 9:55
 */
package stork.core {
import flash.utils.Dictionary;
import flash.utils.describeType;
import flash.utils.getQualifiedClassName;

import stork.core.reference.Reference;
import stork.core.reference.SiblingReference;

import stork.event.EventDispatcher;

public class Node extends EventDispatcher {
    private static var _localRefData:Dictionary  = new Dictionary();
    private static var _globalRefData:Dictionary = new Dictionary();

    private var _name:String;
    private var _parentNode:ContainerNode;

    private var _references:Vector.<Reference>;

    private static function initReferenceData(object:Object, className:String):void {
        var localRefs:Vector.<ReferenceData>  = _localRefData[className]  = new <ReferenceData>[];
        var globalRefs:Vector.<ReferenceData> = _globalRefData[className] = new <ReferenceData>[];

        var type:XML = describeType(object);
        var metadataXML:XML;

        // set variables references
        for each (var variableXML:XML in type.variable) {
            for each(metadataXML in variableXML.metadata) {
                if(metadataXML.@name == "LocalReference") {
                    localRefs[localRefs.length] = new ReferenceData(variableXML.@name, metadataXML.arg.@value);
                }
                else if(metadataXML.@name == "GlobalReference") {
                    globalRefs[localRefs.length] = new ReferenceData(variableXML.@name, metadataXML.arg.@value);
                }
            }
        }

        // set accessor references
        for each (var accessorXML:XML in type.accessor) {
            for each(metadataXML in accessorXML.metadata) {
                if(metadataXML.@name == "LocalReference") {
                    localRefs[localRefs.length] = new ReferenceData(accessorXML.@name, metadataXML.arg.@value);
                }
                else if(metadataXML.@name == "GlobalReference") {
                    globalRefs[localRefs.length] = new ReferenceData(accessorXML.@name, metadataXML.arg.@value);
                }
            }
        }
    }

    public function Node(name:String = "Node") {
        var className:String = getQualifiedClassName(this);

        if(_localRefData[className] == null  && _globalRefData[className] == null)
            initReferenceData(this, className);

        var localRefCount:int = _localRefData[className].length;
        _references = localRefCount > 0 ? new Vector.<Reference>(localRefCount, true) : null;

        for(var i:int = 0; i < localRefCount; i++) {
            var localData:ReferenceData = _localRefData[className][i];

            _references[i] = new SiblingReference(this, localData.propertyName, localData.referencePath);
        }

        _name = name;
    }

    public function get name():String { return _name; }

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

class ReferenceData {
    public var propertyName:String;
    public var referencePath:String;

    public function ReferenceData(propertyName:String, referencePath:String) {
        this.propertyName = propertyName;
        this.referencePath = referencePath;
    }
}