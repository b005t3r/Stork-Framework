/**
 * User: booster
 * Date: 28/01/14
 * Time: 9:35
 */
package stork.core.reference {
import stork.core.Node;
import stork.core.SceneNode;
import stork.event.Event;

public class GlobalReference extends Reference {
    public function GlobalReference(referencing:Node, propertyName:String, path:String) {
        super(referencing, propertyName, path);

        var sceneNode:SceneNode = _referencing.sceneNode;

        if(sceneNode == null) {
            _referencing.addEventListener(Event.ADDED_TO_SCENE, onReferencingAddedToScene);
        }
        else {
            _referencing.addEventListener(Event.REMOVED_FROM_SCENE, onReferencingRemovedFromScene);

            var node:Node = findReferencedNode(sceneNode);

            if(node == null) {
                sceneNode.addEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToScene);
            }
            else {
                setReferenced(node);

                node.addEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);
            }
        }
    }

    override public function dispose():void {
        _referencing.removeEventListener(Event.ADDED_TO_SCENE, onReferencingAddedToScene);
        _referencing.removeEventListener(Event.REMOVED_FROM_SCENE, onReferencingRemovedFromScene);

        var sceneNode:SceneNode = _referencing.sceneNode;

        if(sceneNode != null)
            sceneNode.removeEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToScene);

        if(_referenced != null)
            _referenced.removeEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);

        super.dispose();
    }

    private function onReferencingAddedToScene(event:Event):void {
        _referencing.removeEventListener(Event.ADDED_TO_SCENE, onReferencingAddedToScene);
        _referencing.addEventListener(Event.REMOVED_FROM_SCENE, onReferencingRemovedFromScene);

        var sceneNode:SceneNode = _referencing.sceneNode;
        var node:Node = findReferencedNode(sceneNode);

        if(node == null) {
            sceneNode.addEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToScene);
        }
        else {
            setReferenced(node);

            node.addEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);
        }
    }

    private function onReferencingRemovedFromScene(event:Event):void {
        var sceneNode:SceneNode = _referencing.sceneNode;

        _referencing.removeEventListener(Event.REMOVED_FROM_SCENE, onReferencingRemovedFromScene);
        sceneNode.removeEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToScene);

        if(_referenced != null) {
            _referenced.removeEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);
            setReferenced(null);
        }

        _referencing.addEventListener(Event.ADDED_TO_SCENE, onReferencingAddedToScene);
    }

    private function onSomethingAddedToScene(event:Event):void {
        var sceneNode:SceneNode = event.currentTarget as SceneNode; // this listener is added to SceneNode
        var node:Node = findReferencedNode(sceneNode);

        if(node == null)
            return;

        sceneNode.removeEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToScene);

        setReferenced(node);

        node.addEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);
    }

    private function onReferencedRemovedFromScene(event:Event):void {
        _referenced.removeEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);

        var sceneNode:SceneNode = _referencing.sceneNode;
        var node:Node           = findReferencedNode(sceneNode);

        setReferenced(null);

        if(node == null) {
            sceneNode.addEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToScene);
        }
        else {
            setReferenced(node);

            node.addEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);
        }
    }
}
}
