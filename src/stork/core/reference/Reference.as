/**
 * User: booster
 * Date: 27/01/14
 * Time: 10:02
 */
package stork.core.reference {
import flash.utils.getDefinitionByName;

import stork.core.ContainerNode;
import stork.core.Node;
import stork.core.stork_internal;

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
        var node:Node = findReferencedNodeImpl(container, 0);

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

    private function findReferencedNodeImpl(container:ContainerNode, segmentIndex:int):Node {
        use namespace stork_internal;

        var segment:CompiledReferenceSegment = _compiledSegments[segmentIndex];

        var count:int = container.nodeCount;
        for(var i:int = 0; i < count; i++) {
            var node:Node = container.getNodeAt(i);

            if(node.beingRemoved || ! segment.matches(node))
                continue;

            // last segment
            if(segmentIndex == _compiledSegments.length - 1) {
                return node;
            }
            // middle segment, has to be a ContainerNode
            else {
                var nextNode:Node = findReferencedNodeImpl(node as ContainerNode, segmentIndex + 1);

                if(nextNode != null)
                    return nextNode;
            }
        }

        return null;
    }
}
}

import stork.core.Node;

internal class CompiledReferenceSegment {
    public static const CLASS:int           = 1;
    public static const NODE_NAME:int       = 2;

    public var type:int;
    public var value:*;

    public function CompiledReferenceSegment(type:int, value:*) {
        this.type = type;
        this.value = value;
    }

    public function matches(node:Node):Boolean {
        switch(type) {
            case CompiledReferenceSegment.CLASS:
                return (node is (value as Class));

            case CompiledReferenceSegment.NODE_NAME:
                return node.name == (value as String);

            default:
                throw new Error("invalid segment type: " + type);
        }
    }
}
