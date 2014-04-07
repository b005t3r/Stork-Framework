/**
 * User: booster
 * Date: 30/01/14
 * Time: 11:42
 */
package stork.core.reference {
import flash.system.ApplicationDomain;

import stork.core.Node;

public class Reference {
    protected var _referencing:Node;
    protected var _propertyName:String;
    protected var _path:String;

    public static function getFullClassName(className):String {
        var classNames:Vector.<String> = ApplicationDomain.currentDomain.getQualifiedDefinitionNames();

        var count:int = classNames.length;
        for(var i:int = 0; i < count; i++) {
            var fullClassName:String = classNames[i];

            var index:int = fullClassName.indexOf(className);

            if(index >= 0)
                return fullClassName;
        }

        return null;
    }

    public function Reference(referencing:Node, propertyName:String, path:String) {
        _referencing    = referencing;
        _propertyName   = propertyName;
        _path           = path;
    }

    public function dispose():void { /*do nothing*/ }
}
}
