/**
 * User: booster
 * Date: 30/01/14
 * Time: 11:42
 */
package stork.core.reference {
import stork.core.Node;

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
}
}
