/**
 * User: booster
 * Date: 27/01/14
 * Time: 12:31
 */
package stork.core.reference {
import stork.core.Node;
import stork.core.stork_internal;
import stork.event.Event;

use namespace stork_internal;

public class LocalReference extends NodeReference {
    public static const TAG_NAME:String = "LocalReference";

    public function LocalReference(referencing:Node, propertyName:String, path:String) {
        super(referencing, propertyName, path);

        if(_referencing.parentNode == null) {
            _referencing.stork_internal::addReferenceEventListener(Event.ADDED_TO_PARENT, onReferencingAddedToParent);
        }
        else {
            _referencing.stork_internal::addReferenceEventListener(Event.REMOVED_FROM_PARENT, onReferencingRemovedFromParent);

            var node:Node = findReferencedNode(_referencing.parentNode);

            if(node == null) {
                _referencing.parentNode.stork_internal::addReferenceEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToParent);
            }
            else {
                setReferenced(node);

                node.stork_internal::addReferenceEventListener(Event.REMOVED_FROM_PARENT, onReferencedRemovedFromParent);
                node.stork_internal::addReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene)
            }
        }
    }

    override public function dispose():void {
        _referencing.stork_internal::removeReferenceEventListener(Event.ADDED_TO_PARENT, onReferencingAddedToParent);
        _referencing.stork_internal::removeReferenceEventListener(Event.REMOVED_FROM_PARENT, onReferencingRemovedFromParent);

        if(_referencing.parentNode != null)
            _referencing.parentNode.stork_internal::removeReferenceEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToParent);

        if(_referenced != null) {
            _referenced.stork_internal::removeReferenceEventListener(Event.REMOVED_FROM_PARENT, onReferencedRemovedFromParent);
            _referenced.stork_internal::removeReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);
        }

        super.dispose();
    }

    private function onReferencingAddedToParent(event:Event):void {
        if(event.target != _referencing)
            return;

        _referencing.stork_internal::removeReferenceEventListener(Event.ADDED_TO_PARENT, onReferencingAddedToParent);
        _referencing.stork_internal::addReferenceEventListener(Event.REMOVED_FROM_PARENT, onReferencingRemovedFromParent);

        var node:Node = findReferencedNode(_referencing.parentNode);

        if(node == null) {
            _referencing.parentNode.stork_internal::addReferenceEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToParent);
        }
        else {
            setReferenced(node);

            node.stork_internal::addReferenceEventListener(Event.REMOVED_FROM_PARENT, onReferencedRemovedFromParent);
            node.stork_internal::addReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);
        }
    }

    private function onReferencingRemovedFromParent(event:Event):void {
        if(event.target != _referencing)
            return;

        _referencing.stork_internal::removeReferenceEventListener(Event.REMOVED_FROM_PARENT, onReferencingRemovedFromParent);
        _referencing.parentNode.stork_internal::removeReferenceEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToParent);

        if(_referenced != null) {
            _referenced.stork_internal::removeReferenceEventListener(Event.REMOVED_FROM_PARENT, onReferencedRemovedFromParent);
            _referenced.stork_internal::removeReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);
            setReferenced(null);
        }

        _referencing.stork_internal::addReferenceEventListener(Event.ADDED_TO_PARENT, onReferencingAddedToParent);
    }

    private function onSomethingAddedToParent(event:Event):void {
        if(event.target == _referencing.parentNode)
            return;

        var node:Node = findReferencedNode(_referencing.parentNode);

        if(node == null)
            return;

        _referencing.parentNode.stork_internal::removeReferenceEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToParent);

        setReferenced(node);

        node.stork_internal::addReferenceEventListener(Event.REMOVED_FROM_PARENT, onReferencedRemovedFromParent);
        node.stork_internal::addReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);
    }

    private function onReferencedRemovedFromParent(event:Event):void {
        if(event.target != _referenced)
            return;

        _referenced.stork_internal::removeReferenceEventListener(Event.REMOVED_FROM_PARENT, onReferencedRemovedFromParent);
        _referenced.stork_internal::removeReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene)

        var node:Node = findReferencedNode(_referencing.parentNode);

        setReferenced(null);

        if(node == null) {
            _referencing.parentNode.stork_internal::addReferenceEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToParent);
        }
        else {
            setReferenced(node);

            node.stork_internal::addReferenceEventListener(Event.REMOVED_FROM_PARENT, onReferencedRemovedFromParent);
            node.stork_internal::addReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);
        }
    }

    private function onReferencedRemovedFromScene(event:Event):void {
        var node:Node = findReferencedNode(_referencing.parentNode);

        if(node == _referenced)
            return;

        if(node != _referenced) {
            _referenced.stork_internal::removeReferenceEventListener(Event.REMOVED_FROM_PARENT, onReferencedRemovedFromParent);
            _referenced.stork_internal::removeReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);

            setReferenced(null);
        }

        if(node == null) {
            _referencing.parentNode.stork_internal::addReferenceEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToParent);
        }
        else {
            setReferenced(node);

            node.stork_internal::addReferenceEventListener(Event.REMOVED_FROM_PARENT, onReferencedRemovedFromParent);
            node.stork_internal::addReferenceEventListener(Event.REMOVED_FROM_SCENE, onReferencedRemovedFromScene);
        }
    }
}
}
