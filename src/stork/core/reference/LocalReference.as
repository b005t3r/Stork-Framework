/**
 * User: booster
 * Date: 27/01/14
 * Time: 12:31
 */
package stork.core.reference {
import stork.core.Node;
import stork.event.Event;

public class LocalReference extends Reference {
    public function LocalReference(referencing:Node, propertyName:String, path:String) {
        super(referencing, propertyName, path);

        if(_referencing.parentNode == null) {
            _referencing.addEventListener(Event.ADDED_TO_PARENT, onReferencingAddedToParent);
        }
        else {
            _referencing.addEventListener(Event.REMOVED_FROM_PARENT, onReferencingRemovedFromParent);

            var node:Node = findReferencedNode(_referencing.parentNode);

            if(node == null) {
                _referencing.parentNode.addEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToParent);
            }
            else {
                setReferenced(node);

                node.addEventListener(Event.REMOVED_FROM_PARENT, onReferencedRemovedFromParent);
            }
        }
    }

    override public function dispose():void {
        _referencing.removeEventListener(Event.ADDED_TO_PARENT, onReferencingAddedToParent);
        _referencing.removeEventListener(Event.REMOVED_FROM_PARENT, onReferencingRemovedFromParent);

        if(_referencing.parentNode != null)
            _referencing.parentNode.removeEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToParent);

        if(_referenced != null)
            _referenced.removeEventListener(Event.REMOVED_FROM_PARENT, onReferencedRemovedFromParent);

        super.dispose();
    }

    private function onReferencingAddedToParent(event:Event):void {
        if(event.target != _referencing)
            return;

        _referencing.removeEventListener(Event.ADDED_TO_PARENT, onReferencingAddedToParent);
        _referencing.addEventListener(Event.REMOVED_FROM_PARENT, onReferencingRemovedFromParent);

        var node:Node = findReferencedNode(_referencing.parentNode);

        if(node == null) {
            _referencing.parentNode.addEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToParent);
        }
        else {
            setReferenced(node);

            node.addEventListener(Event.REMOVED_FROM_PARENT, onReferencedRemovedFromParent);
        }
    }

    private function onReferencingRemovedFromParent(event:Event):void {
        if(event.target != _referencing)
            return;

        _referencing.removeEventListener(Event.REMOVED_FROM_PARENT, onReferencingRemovedFromParent);
        _referencing.parentNode.removeEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToParent);

        if(_referenced != null) {
            _referenced.removeEventListener(Event.REMOVED_FROM_PARENT, onReferencedRemovedFromParent);
            setReferenced(null);
        }

        _referencing.addEventListener(Event.ADDED_TO_PARENT, onReferencingAddedToParent);
    }

    private function onSomethingAddedToParent(event:Event):void {
        if(event.target == _referencing.parentNode)
            return;

        var node:Node = findReferencedNode(_referencing.parentNode);

        if(node == null)
            return;

        _referencing.parentNode.removeEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToParent);

        setReferenced(node);

        node.addEventListener(Event.REMOVED_FROM_PARENT, onReferencedRemovedFromParent);
    }

    private function onReferencedRemovedFromParent(event:Event):void {
        if(event.target != _referenced)
            return;

        _referenced.removeEventListener(Event.REMOVED_FROM_PARENT, onReferencedRemovedFromParent);
        setReferenced(null);

        _referencing.parentNode.addEventListener(Event.ADDED_TO_PARENT, onSomethingAddedToParent);
    }
}
}
