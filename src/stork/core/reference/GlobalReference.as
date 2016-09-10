/**
 * User: booster
 * Date: 28/01/14
 * Time: 9:35
 */
package stork.core.reference {
import flash.utils.getDefinitionByName;

import medkit.object.ObjectUtil;

import stork.core.ContainerNode;

import stork.core.ContainerNode;
import stork.core.Node;
import stork.core.SceneNode;
import stork.core.stork_internal;
import stork.event.Event;

use namespace stork_internal;

public class GlobalReference extends NodeReference {
    public static const TAG_NAME:String             = "GlobalReference";
    public static const ROOT_PATH_SEPARATOR:String  = "://";

    private static const CLASS:int                  = 1;
    private static const NODE_NAME:int              = 2;

    private var _relativeToRoot:Boolean;
    private var _rootType:int;
    private var _rootValue:*;

    public function GlobalReference(referencing:Node, propertyName:String, path:String) {
        var rootSeparatorIndex:int = path.indexOf(ROOT_PATH_SEPARATOR);

        if(rootSeparatorIndex >= 0) {
            _relativeToRoot     = true;
            var rootName:String = path.substring(0, rootSeparatorIndex);
            path                = path.substring(rootSeparatorIndex + ROOT_PATH_SEPARATOR.length);

            if(path.length == 0)
                path = null;

            // class name
            if(rootName.charCodeAt(0) == "@".charCodeAt(0)) {
                rootName        = rootName.substr(1, rootName.length - 1);
                rootName        = ObjectUtil.getFullClassName(rootName);
                var clazz:Class = getDefinitionByName(rootName) as Class;

                _rootType   = CLASS;
                _rootValue  = clazz;
            }
            // component name
            else {
                _rootType   = NODE_NAME;
                _rootValue  = rootName;
            }
        }
        else {
            _relativeToRoot = false;
        }

        super(referencing, propertyName, path);

        var sceneNode:SceneNode = _referencing.sceneNode;

        if(sceneNode == null) {
            _referencing.stork_internal::addReferenceEventListener(Event.ADDED_TO_SCENE, onReferencingAddedToScene);
        }
        else {
            _referencing.stork_internal::addReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencingRemovedFromScene);

            var node:Node = findReferencedNode(sceneNode);

            if(node == null) {
                sceneNode.stork_internal::addReferenceEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToScene);
            }
            else {
                setReferenced(node);

                node.stork_internal::addReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);
            }
        }
    }

    override public function dispose():void {
        _referencing.stork_internal::removeReferenceEventListener(Event.ADDED_TO_SCENE, onReferencingAddedToScene);
        _referencing.stork_internal::removeReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencingRemovedFromScene);

        var sceneNode:SceneNode = _referencing.sceneNode;

        if(sceneNode != null)
            sceneNode.stork_internal::removeReferenceEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToScene);

        if(_referenced != null)
            _referenced.stork_internal::removeReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);

        super.dispose();
    }

    override protected function findReferencedNode(container:ContainerNode, nodeToIgnore:Node = null):Node {
        var sceneNode:SceneNode = container as SceneNode;

        if(sceneNode == null)
            throw new ArgumentError("SceneNode has to be passed as 'container' to findReferencedNode() for GlobalReferences");

        if(! _relativeToRoot)
            return super.findReferencedNode(sceneNode, nodeToIgnore);

        var rootNode:ContainerNode = findRootNode(nodeToIgnore);

        if(rootNode == null)
            return null;

        if(_compiledSegments.length == 0)
            return rootNode;

        return super.findReferencedNode(rootNode, nodeToIgnore);
    }

    private function findRootNode(nodeToIgnore:Node):ContainerNode {
        var parent:ContainerNode = _referencing is ContainerNode ? ContainerNode(_referencing) : _referencing.parentNode;

        while(parent != null) {
            if(_rootType == CLASS) {
                if(parent is (_rootValue as Class) && parent != nodeToIgnore)
                    return parent;
            }
            else {
                if(parent.name == (_rootValue as String) && parent != nodeToIgnore)
                    return parent;
            }

            parent = parent.parentNode;
        }

        return null;
    }

    private function onReferencingAddedToScene(event:Event):void {
        _referencing.stork_internal::removeReferenceEventListener(Event.ADDED_TO_SCENE, onReferencingAddedToScene);
        _referencing.stork_internal::addReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencingRemovedFromScene);

        var sceneNode:SceneNode = _referencing.sceneNode;
        var node:Node = findReferencedNode(sceneNode);

        if(node == null) {
            sceneNode.stork_internal::addReferenceEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToScene);
        }
        else {
            setReferenced(node);

            node.stork_internal::addReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);
        }
    }

    private function onReferencingRemovedFromScene(event:Event):void {
        var sceneNode:SceneNode = _referencing.sceneNode;

        _referencing.stork_internal::removeReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencingRemovedFromScene);
        sceneNode.stork_internal::removeReferenceEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToScene);

        if(_referenced != null) {
            _referenced.stork_internal::removeReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);
            setReferenced(null);
        }

        _referencing.stork_internal::addReferenceEventListener(Event.ADDED_TO_SCENE, onReferencingAddedToScene);
    }

    private function onSomethingAddedToScene(event:Event):void {
        var sceneNode:SceneNode = event.currentTarget as SceneNode; // this listener is added to SceneNode
        var node:Node = findReferencedNode(sceneNode);

        if(node == null)
            return;

        sceneNode.stork_internal::removeReferenceEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToScene);

        setReferenced(node);

        node.stork_internal::addReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);
    }

    private function onReferencedRemovedFromScene(event:Event):void {
        if(_referenced == null) {
            trace("WARNING: onReferencedRemovedFromScene() called while _referenced == null")
            return;
        }

        _referenced.stork_internal::removeReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);

        var sceneNode:SceneNode = _referencing.sceneNode;
        var node:Node = findReferencedNode(sceneNode, _referenced);

        setReferenced(null);

        if(node == null) {
            sceneNode.stork_internal::addReferenceEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToScene);
        }
        else {
            setReferenced(node);

            node.stork_internal::addReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);
        }
    }
}
}
