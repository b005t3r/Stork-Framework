/**
 * User: booster
 * Date: 24/01/14
 * Time: 11:33
 */
package stork.event {
import flash.utils.Dictionary;

import stork.core.Node;
import stork.core.stork_internal;

use namespace stork_internal;

public class EventDispatcher implements IEventDispatcher {
    private static var _bubbleChains:Array = [];

    private var _eventListeners:Dictionary;
    private var _referenceEventListeners:Dictionary;

    public function addEventListener(type:String, listener:Function):void {
        if(_eventListeners == null)
            _eventListeners = new Dictionary();

        var listeners:Vector.<Function> = _eventListeners[type] as Vector.<Function>;
        if(listeners == null)
            _eventListeners[type] = new <Function>[listener];
        else if(listeners.indexOf(listener) == -1) // check for duplicates
            listeners[listeners.length] = listener;
    }

    stork_internal function addReferenceEventListener(type:String, listener:Function):void {
        if(_referenceEventListeners == null)
            _referenceEventListeners = new Dictionary();

        var listeners:Vector.<Function> = _referenceEventListeners[type] as Vector.<Function>;
        if(listeners == null)
            _referenceEventListeners[type] = new <Function>[listener];
        else if(listeners.indexOf(listener) == -1) // check for duplicates
            listeners[listeners.length] = listener;
    }

    public function removeEventListener(type:String, listener:Function):void {
        if(_eventListeners == null)
            return;

        var listeners:Vector.<Function> = _eventListeners[type] as Vector.<Function>;

        if(listeners == null)
            return;

        var numListeners:int = listeners.length;
        var remainingListeners:Vector.<Function> = new <Function>[];

        for(var i:int = 0; i < numListeners; ++i) {
            var otherListener:Function = listeners[i];
            if(otherListener != listener) remainingListeners[remainingListeners.length] = otherListener;
        }

        _eventListeners[type] = remainingListeners;
    }

    stork_internal function removeReferenceEventListener(type:String, listener:Function):void {
        if(_referenceEventListeners == null)
            return;

        var listeners:Vector.<Function> = _referenceEventListeners[type] as Vector.<Function>;

        if(listeners == null)
            return;

        var numListeners:int = listeners.length;
        var remainingListeners:Vector.<Function> = new <Function>[];

        for(var i:int = 0; i < numListeners; ++i) {
            var otherListener:Function = listeners[i];
            if(otherListener != listener) remainingListeners[remainingListeners.length] = otherListener;
        }

        _referenceEventListeners[type] = remainingListeners;
    }

    public function removeEventListeners(type:String = null):void {
        if(type && _eventListeners)
            delete _eventListeners[type];
        else
            _eventListeners = null;
    }

    public function dispatchEvent(event:Event):void {
        var bubbles:Boolean = event.bubbles;

        if(!bubbles && (_eventListeners == null || ! (event.type in _eventListeners)) && (_referenceEventListeners == null || ! (event.type in _referenceEventListeners)))
            return; // no need to do anything

        //event.stork_internal::reset();

        // we save the current target and restore it later;
        // this allows users to re-dispatch events without creating a clone.

        var previousTarget:IEventDispatcher = event.target;
        event.setTarget(this);

        if(bubbles && this is Node) bubbleEvent(event);
        else                        invokeEvent(event);

        if(previousTarget) event.setTarget(previousTarget);
    }

    public function hasEventListener(type:String):Boolean {
        var listeners:Vector.<Function> = _eventListeners != null
            ? _eventListeners[type] as Vector.<Function>
            : null
        ;

        if(listeners == null || listeners.length == 0) {
            var referenceListeners:Vector.<Function> = _referenceEventListeners != null
                ? _referenceEventListeners[type] as Vector.<Function>
                : null
            ;

            return referenceListeners != null ? referenceListeners.length != 0 : false;
        }
        else {
            return false;
        }
    }

    /**
     * Invokes an event on the current object. This method does not do any bubbling, nor
     * does it back-up and restore the previous target on the event. The 'dispatchEvent'
     * method uses this method internally. */
    internal function invokeEvent(event:Event):Boolean {
        var referenceListeners:Vector.<Function> = _referenceEventListeners != null
            ? _referenceEventListeners[event.type] as Vector.<Function>
            : null
        ;

        var numReferenceListeners:int = referenceListeners == null ? 0 : referenceListeners.length;

        if(numReferenceListeners) {
            event.setCurrentTarget(this);

            // we can enumerate directly over the vector, because:
            // when somebody modifies the list while we're looping, "addEventListener" is not
            // problematic, and "removeEventListener" will create a new Vector, anyway.

            for(var i:int = 0; i < numReferenceListeners; ++i) {
                var referenceListener:Function  = referenceListeners[i] as Function;
                var numReferenceArgs:int        = referenceListener.length;

                if(numReferenceArgs == 0)       referenceListener();
                else if(numReferenceArgs == 1)  referenceListener(event);

                if(event.stopsImmediatePropagation || event.stopsPropagation)
                    throw new Error("reference listener cannot stop event propagation");
            }
        }

        var listeners:Vector.<Function> = _eventListeners != null
            ? _eventListeners[event.type] as Vector.<Function>
            : null
        ;

        var numListeners:int = listeners == null ? 0 : listeners.length;

        if(numListeners) {
            event.setCurrentTarget(this);

            // we can enumerate directly over the vector, because:
            // when somebody modifies the list while we're looping, "addEventListener" is not
            // problematic, and "removeEventListener" will create a new Vector, anyway.

            for(var j:int = 0; j < numListeners; ++j) {
                var listener:Function   = listeners[j] as Function;
                var numArgs:int         = listener.length;

                if(numArgs == 0)        listener();
                else if(numArgs == 1)   listener(event);

                if(event.stopsImmediatePropagation)
                    return true;
            }

            return event.stopsPropagation;
        }
        else {
            return false;
        }
    }

    internal function bubbleEvent(event:Event):void {
        // we determine the bubble chain before starting to invoke the listeners.
        // that way, changes done by the listeners won't affect the bubble chain.

        var chain:Vector.<EventDispatcher>;
        var element:Node = this as Node;
        var length:int = 1;

        if(_bubbleChains.length > 0) {
            chain = _bubbleChains.pop();
            chain[0] = element;
        }
        else chain = new <EventDispatcher>[element];

        while((element = element.parentNode) != null)
            chain[int(length++)] = element;

        for(var i:int = 0; i < length; ++i) {
            var stopPropagation:Boolean = chain[i].invokeEvent(event);
            if(stopPropagation) break;
        }

        chain.length = 0;
        _bubbleChains[_bubbleChains.length] = chain;
    }

}
}
