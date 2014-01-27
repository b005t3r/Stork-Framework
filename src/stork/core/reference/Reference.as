/**
 * User: booster
 * Date: 27/01/14
 * Time: 10:02
 */
package stork.core.reference {
import flash.utils.getDefinitionByName;

import stork.core.ContainerNode;
import stork.core.Node;

public class Reference {
    protected var _referencing:Node;
    protected var _propertyName:String;
    protected var _path:String;

    protected var _referenced:Node;

    protected var _compiledSegments:Vector.<CompiledReferenceSegment>;

    public function Reference(referencing:Node, propertyName:String, path:String) {
        _referencing    = referencing;
        _propertyName   = propertyName;
        _path           = path;

        compile();
    }

    public function dispose():void { /*do nothing*/ }

    protected function findReferencedNode(container:ContainerNode):Node {
        var node:Node = container;

        var count:int = _compiledSegments.length;
        for(var i:int = 0; i < count; i++) {
            if(node == null)
                break;

            var segment:CompiledReferenceSegment = _compiledSegments[i];

            switch(segment.type) {
                case CompiledReferenceSegment.CLASS:
                    node = (node as ContainerNode).getNodeByClass(segment.value as Class);
                    break;

                case CompiledReferenceSegment.NODE_NAME:
                    node = (node as ContainerNode).getNodeByName(segment.value as String);
                    break;

                default:
                    throw new Error("invalid segment type: " + segment.type);
            }
        }

        return node;
    }

    protected function setReferenced(value:Node):void {
        if(value != null) {
            if(_referenced != null)
                throw new ArgumentError("unset previously referenced property before setting a new one");

            _referenced                 = value;
            _referencing[_propertyName] = value;

            if(value.parentNode == null)
                throw new UninitializedError("referenced object is not added to parent");
        }
        else {
            if(_referenced == null)
                throw new ArgumentError("property already unset");

            _referenced                 = null;
            _referencing[_propertyName] = null;
        }
    }

    private function compile():void {
        var pathParts:Array = _path.split('/');

        _compiledSegments = new <CompiledReferenceSegment>[];

        var count:int = pathParts.length;
        for(var i:int = 0; i < count; i++) {
            var pathPart:String = pathParts[i];

            var segment:CompiledReferenceSegment;

            // class name
            if(pathPart.charCodeAt(0) == "@".charCodeAt(0)) {
                pathPart = pathPart.substr(1, pathPart.length - 1);
                var clazz:Class = getDefinitionByName(pathPart) as Class;

                segment = new CompiledReferenceSegment(CompiledReferenceSegment.CLASS, clazz);
            }
            // component name
            else {
                segment = new CompiledReferenceSegment(CompiledReferenceSegment.NODE_NAME, pathPart);
            }

            _compiledSegments[_compiledSegments.length] = segment;
        }
    }
}
}

internal class CompiledReferenceSegment {
    public static const CLASS:int           = 1;
    public static const NODE_NAME:int       = 2;

    public var type:int;
    public var value:*;

    public function CompiledReferenceSegment(type:int, value:*) {
        this.type = type;
        this.value = value;
    }
}
