/**
 * User: booster
 * Date: 24/01/14
 * Time: 9:09
 */
package stork.event {

public interface IEventDispatcher {
    /** Registers an event listener at a certain object. */
    function addEventListener(type:String, listener:Function):void

    /** Removes an event listener from the object. */
    function removeEventListener(type:String, listener:Function):void

    /** Removes all event listeners with a certain type, or all of them if type is null.
     *  Be careful when removing all event listeners: you never know who else was listening. */
    function removeEventListeners(type:String = null):void

    /** Dispatches an event to all objects that have registered listeners for its type.
     *  If an event with enabled 'bubble' property is dispatched to a display object, it will
     *  travel up along the line of parents, until it either hits the root object or someone
     *  stops its propagation manually. */
    function dispatchEvent(event:Event):void

    /** Returns if there are listeners registered for a certain event type. */
    function hasEventListener(type:String):Boolean
}
}
