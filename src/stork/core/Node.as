/**
 * User: booster
 * Date: 24/01/14
 * Time: 9:55
 */
package stork.core {
import flash.utils.Dictionary;
import flash.utils.describeType;
import flash.utils.getQualifiedClassName;

import stork.core.reference.GlobalReference;
import stork.core.reference.LocalReference;
import stork.core.reference.Reference;
import stork.event.EventDispatcher;

public class Node extends EventDispatcher {
    private static const LOCAL_REFERENCE:String     = "LocalReference";
    private static const GLOBAL_REFERENCE:String    = "GlobalReference";

    private static var _localRefData:Dictionary     = new Dictionary();
    private static var _globalRefData:Dictionary    = new Dictionary();

    private var _name:String;
    private var _parentNode:ContainerNode;

    private var _references:Vector.<Reference>;

    stork_internal var beingAdded:Boolean       = false;
    stork_internal var beingRemoved:Boolean     = false;

    public function Node(name:String = "Node") {
        _name = name;

        var className:String = getQualifiedClassName(this);

        if(_localRefData[className] == null  && _globalRefData[className] == null)
            initReferenceData(this, className);

        injectGlobalReferences(className);
        injectLocalReferences(className);
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

    private static function initReferenceData(object:Object, className:String):void {
        var localRefs:Vector.<ReferenceData>  = _localRefData[className]  = new <ReferenceData>[];
        var globalRefs:Vector.<ReferenceData> = _globalRefData[className] = new <ReferenceData>[];

        var type:XML = describeType(object);
        var metadataXML:XML;

        // set variables references
        for each (var variableXML:XML in type.variable) {
            for each(metadataXML in variableXML.metadata) {
                if(metadataXML.@name == LOCAL_REFERENCE) {
                    localRefs[localRefs.length] = new ReferenceData(variableXML.@name, metadataXML.arg.@value);
                }
                else if(metadataXML.@name == GLOBAL_REFERENCE) {
                    globalRefs[globalRefs.length] = new ReferenceData(variableXML.@name, metadataXML.arg.@value);
                }
            }
        }

        // set accessor references
        for each (var accessorXML:XML in type.accessor) {
            for each(metadataXML in accessorXML.metadata) {
                if(metadataXML.@name == LOCAL_REFERENCE) {
                    localRefs[localRefs.length] = new ReferenceData(accessorXML.@name, metadataXML.arg.@value);
                }
                else if(metadataXML.@name == GLOBAL_REFERENCE) {
                    globalRefs[globalRefs.length] = new ReferenceData(accessorXML.@name, metadataXML.arg.@value);
                }
            }
        }
    }

    private function injectGlobalReferences(className:String):void {
        var globalRefs:Vector.<ReferenceData> = _globalRefData[className];
        var globalRefCount:int = globalRefs.length;
        _references = globalRefCount > 0 ? new Vector.<Reference>(globalRefCount, true) : null;

        for(var i:int = 0; i < globalRefCount; i++) {
            var globalData:ReferenceData = globalRefs[i];

            _references[i] = new GlobalReference(this, globalData.propertyName, globalData.referencePath);
        }
    }

    private function injectLocalReferences(className:String):void {
        var localRefs:Vector.<ReferenceData> = _localRefData[className];
        var localRefCount:int = localRefs.length;
        _references = localRefCount > 0 ? new Vector.<Reference>(localRefCount, true) : null;

        for(var i:int = 0; i < localRefCount; i++) {
            var localData:ReferenceData = localRefs[i];

            _references[i] = new LocalReference(this, localData.propertyName, localData.referencePath);
        }
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