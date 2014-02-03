/**
 * User: booster
 * Date: 03/02/14
 * Time: 15:03
 */
package stork.core.reference {
import flash.utils.getDefinitionByName;

import stork.core.Node;
import stork.core.SceneNode;
import stork.event.Event;
import stork.event.SceneObjectEvent;

public class ObjectReference extends Reference {
    public static const TAG_NAME:String = "ObjectReference";

    private static const CLASS:int      = 1;
    private static const NODE_NAME:int  = 2;

    private var _type:int;
    private var _value:*;

    private var _referenced:Object;

    public function ObjectReference(referencing:Node, propertyName:String, path:String) {
        super(referencing, propertyName, path);

        compile();

        var sceneNode:SceneNode = _referencing.sceneNode;

        if(sceneNode == null) {
            _referencing.addEventListener(Event.ADDED_TO_SCENE, onReferencingAddedToScene);
        }
        else {
            _referencing.addEventListener(Event.REMOVED_FROM_SCENE, onReferencingRemovedFromScene);

            var obj:Object = findReferencedNode(sceneNode);

            if(obj == null) {
                sceneNode.addEventListener(SceneObjectEvent.OBJECT_ADDED_TO_SCENE, onObjectAddedToScene);
            }
            else {
                setReferenced(obj);

                sceneNode.addEventListener(SceneObjectEvent.OBJECT_REMOVED_FROM_SCENE, onObjectRemovedFromScene);
            }
        }
    }

    override public function dispose():void {
        _referencing.removeEventListener(Event.ADDED_TO_SCENE, onReferencingAddedToScene);
        _referencing.removeEventListener(Event.REMOVED_FROM_SCENE, onReferencingRemovedFromScene);

        var sceneNode:SceneNode = _referencing.sceneNode;

        if(sceneNode != null) {
            sceneNode.removeEventListener(SceneObjectEvent.OBJECT_ADDED_TO_SCENE, onObjectAddedToScene);
            sceneNode.removeEventListener(SceneObjectEvent.OBJECT_REMOVED_FROM_SCENE, onObjectRemovedFromScene);
        }

        super.dispose();
    }

    private function onReferencingAddedToScene(event:Event):void {
        _referencing.removeEventListener(Event.ADDED_TO_SCENE, onReferencingAddedToScene);
        _referencing.addEventListener(Event.REMOVED_FROM_SCENE, onReferencingRemovedFromScene);

        var sceneNode:SceneNode = _referencing.sceneNode;
        var obj:Object = findReferencedNode(sceneNode);

        if(obj == null) {
            sceneNode.addEventListener(SceneObjectEvent.OBJECT_ADDED_TO_SCENE, onObjectAddedToScene);
        }
        else {
            setReferenced(obj);

            sceneNode.addEventListener(SceneObjectEvent.OBJECT_REMOVED_FROM_SCENE, onObjectRemovedFromScene);
        }
    }

    private function onReferencingRemovedFromScene(event:Event):void {
        var sceneNode:SceneNode = _referencing.sceneNode;

        _referencing.removeEventListener(Event.REMOVED_FROM_SCENE, onReferencingRemovedFromScene);

        if(_referenced == null) {
            sceneNode.removeEventListener(SceneObjectEvent.OBJECT_ADDED_TO_SCENE, onObjectAddedToScene);
        }
        else {
            sceneNode.removeEventListener(SceneObjectEvent.OBJECT_REMOVED_FROM_SCENE, onObjectRemovedFromScene);
            setReferenced(null);
        }

        _referencing.addEventListener(Event.ADDED_TO_SCENE, onReferencingAddedToScene);
    }

    private function onObjectAddedToScene(event:SceneObjectEvent):void {
        var sceneNode:SceneNode = event.sceneNode;
        var obj:Object = findReferencedNode(sceneNode);

        if(obj == null)
            return;

        sceneNode.removeEventListener(SceneObjectEvent.OBJECT_ADDED_TO_SCENE, onObjectAddedToScene);

        setReferenced(obj);

        sceneNode.addEventListener(SceneObjectEvent.OBJECT_REMOVED_FROM_SCENE, onObjectRemovedFromScene);
    }

    private function onObjectRemovedFromScene(event:SceneObjectEvent):void {
        if(event.object != _referenced)
            return;

        var sceneNode:SceneNode = event.sceneNode;
        var obj:Object          = findReferencedNode(sceneNode, _referenced);

        setReferenced(null);

        if(obj == null) {
            sceneNode.removeEventListener(SceneObjectEvent.OBJECT_REMOVED_FROM_SCENE, onObjectRemovedFromScene);
            sceneNode.addEventListener(SceneObjectEvent.OBJECT_ADDED_TO_SCENE, onObjectAddedToScene);
        }
        else {
            setReferenced(obj);
        }
    }

    private function compile():void {
        var name:String = _path;

        // class name
        if(name.charCodeAt(0) == "@".charCodeAt(0)) {
            name = name.substr(1, name.length - 1);
            var clazz:Class = getDefinitionByName(name) as Class;

            _type    = CLASS;
            _value   = clazz;
        }
        // component name
        else {
            _type    = NODE_NAME;
            _value   = name;
        }
    }

    private function findReferencedNode(sceneNode:SceneNode, ignoredObject:Object = null):Object {
        var count:int = sceneNode.objectCount;

        for(var i:int = 0; i < count; ++i) {
            var obj:Object  = sceneNode.getObjectAt(i);
            var name:String = sceneNode.getObjectNameAt(i);

            if(obj == ignoredObject || ! matches(obj, name))
                continue;

            return obj;
        }

        return null;
    }

    private function matches(obj:Object, name:String):Boolean {
        switch(_type) {
            case CLASS:
                return (obj is (_value as Class));

            case NODE_NAME:
                return name == (_value as String);

            default:
                throw new Error("invalid segment type: " + _type);
        }
    }

    private function setReferenced(value:Object):void {
        if(value != null) {
            if(_referenced != null)
                throw new ArgumentError("unset previously referenced property before setting a new one");

            _referenced                 = value;
            _referencing[_propertyName] = value;
        }
        else {
            if(_referenced == null)
                throw new ArgumentError("referenced property already unset");

            _referenced                 = null;
            _referencing[_propertyName] = null;
        }
    }
}
}
