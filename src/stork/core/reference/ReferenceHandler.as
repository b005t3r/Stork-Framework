/**
 * User: booster
 * Date: 05/01/15
 * Time: 15:31
 */
package stork.core.reference {

public class ReferenceHandler {
    public static const TAG_NAME:String = "OnReferenceChanged";

    private var _properties:Object = {}; // String(name) -> Boolean(is set)
    private var _setCount:int;
    private var _allCount:int;

    private var _handlerFunc:Function; // function(allInitialized:Boolean):void

    public function ReferenceHandler(handlerFunc:Function, propertyNames:Vector.<String>) {
        _handlerFunc = handlerFunc;

        var count:int = propertyNames.length;
        for(var i:int = 0; i < count; ++i) {
            var name:String = propertyNames[i];

            registerProperty(name);
        }
    }

    public function isObservingProperty(name:String):Boolean {
        return _properties.hasOwnProperty(name);
    }

    public function propertyChanged(name:String, isSet:Boolean):void {
        if(! _properties.hasOwnProperty(name))
            throw ArgumentError("property '" + name + "' is not being observed");

        var wasSet:Boolean = _properties[name];

        if(wasSet != isSet)
            _properties[name] = isSet;

        if(! wasSet) {
            if(! isSet)
                throw new Error("unsetting an already unset property");
                //return;

            ++_setCount;

            if(_setCount == _allCount)
                _handlerFunc(true);
        }
        else /* if(wasSet) */ {
            if(! isSet) {
                --_setCount;

                // call only if all were set before
                if(_setCount == _allCount - 1)
                    _handlerFunc(false);
            }
            else if(_setCount == _allCount) {
                throw new Error("setting an already set property");

                //_handlerFunc(false);
                //_handlerFunc(true);
            }
        }
    }

    private function registerProperty(name:String):void {
        if(_properties.hasOwnProperty(name))
            throw ArgumentError("property '" + name + "' is already being observed");

        _properties[name] = false;
        ++_allCount;
    }
}
}
