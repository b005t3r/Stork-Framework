/**
 * User: booster
 * Date: 30/01/14
 * Time: 11:42
 */
package stork.core.reference {
import stork.core.Node;
import stork.core.stork_internal;

use namespace stork_internal;

public class Reference {
    protected var _referencing:Node;
    protected var _propertyName:String;
    protected var _path:String;

    public function Reference(referencing:Node, propertyName:String, path:String) {
        _referencing    = referencing;
        _propertyName   = propertyName;
        _path           = path;
    }

    public function dispose():void { /*do nothing*/ }

    protected function refreshReferenceHandlers(isSet:Boolean):void {
        if(_referencing.stork_internal::_referenceHandlers == null)
            return;

        var count:int = _referencing.stork_internal::_referenceHandlers.length;

        for(var i:int = 0; i < count; ++i) {
            var handler:ReferenceHandler = _referencing.stork_internal::_referenceHandlers[i];

            if(!handler.isObservingProperty(_propertyName))
                continue;

            handler.propertyChanged(_propertyName, isSet);
        }
    }

}
}
