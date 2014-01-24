/**
 * User: booster
 * Date: 24/01/14
 * Time: 11:03
 */
package stork.event {
import flash.utils.getQualifiedClassName;

import stork.core.stork_internal;

use namespace stork_internal;

public class Event {
    public static const ADDED_TO_PARENT:String      = "addedToParentNode";
    public static const ADDED_TO_STAGE:String       = "addedToSceneNode";

    public static const REMOVED_FROM_PARENT:String  = "removedFromParentNode";
    public static const REMOVED_FROM_STAGE:String   = "removedFromSceneNode";

    private var _target:IEventDispatcher;
    private var _currentTarget:IEventDispatcher;
    private var _type:String;
    private var _bubbles:Boolean;
    private var _stopsPropagation:Boolean;
    private var _stopsImmediatePropagation:Boolean;

    /** Creates an event object that can be passed to listeners. */
    public function Event(type:String, bubbles:Boolean = false) {
        _type = type;
        _bubbles = bubbles;
    }

    /** Prevents listeners at the next bubble stage from receiving the event. */
    public function stopPropagation():void { _stopsPropagation = true; }

    /** Prevents any other listeners from receiving the event. */
    public function stopImmediatePropagation():void { _stopsPropagation = _stopsImmediatePropagation = true; }

    /** Returns a description of the event, containing type and bubble information. */
    public function toString():String { return "[" + getQualifiedClassName(this).split("::").pop() + " type=\"" + _type + "\" bubbles=" + _bubbles + "]"; }

    /** Indicates if event will bubble. */
    public function get bubbles():Boolean { return _bubbles; }

    /** The object that dispatched the event. */
    public function get target():IEventDispatcher { return _target; }

    /** The object the event is currently bubbling at. */
    public function get currentTarget():IEventDispatcher { return _currentTarget; }

    /** A string that identifies the event. */
    public function get type():String { return _type; }

    // properties for internal use

    internal function setTarget(value:IEventDispatcher):void { _target = value; }
    internal function setCurrentTarget(value:IEventDispatcher):void { _currentTarget = value; }

    internal function get stopsPropagation():Boolean { return _stopsPropagation; }
    internal function get stopsImmediatePropagation():Boolean { return _stopsImmediatePropagation; }

    // event pooling

    stork_internal function reset():Event {
        _target = _currentTarget = null;
        _stopsPropagation = _stopsImmediatePropagation = false;

        return this;
    }
}
}
