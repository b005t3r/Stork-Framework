/**
 * User: booster
 * Date: 30/01/14
 * Time: 11:50
 */
package stork.core.reference {
import flash.utils.Dictionary;
import flash.utils.describeType;
import flash.utils.getQualifiedClassName;

import stork.core.Node;

import stork.core.stork_internal;

use namespace stork_internal;

public class ReferenceUtil {
    private static var _referenceClasses:Dictionary = new Dictionary(); // referenceTag -> referenceImplClass
    private static var _referenceData:Dictionary    = new Dictionary(); // nodeClassName -> Vector.<ReferenceData>

    // static initializer
    {
        ReferenceUtil.registerReferenceClass(LocalReference, LocalReference.TAG_NAME);
        ReferenceUtil.registerReferenceClass(GlobalReference, GlobalReference.TAG_NAME);
        ReferenceUtil.registerReferenceClass(ObjectReference, ObjectReference.TAG_NAME);
    }

    public static function registerReferenceClass(clazz:Class, tagName:String):void {
        _referenceClasses[tagName] = clazz;
    }

    stork_internal static function injectReferences(node:Node):void {
        if(node._references != null)
            throw ArgumentError("node " + node + " already has injected references");

        var className:String            = getQualifiedClassName(node);
        var refs:Vector.<ReferenceData> = initReferenceData(node, className);
        var refCount:int                = refs.length;

        if(refCount == 0) return;

        node._references = new Vector.<Reference>(refCount, true);

        for(var i:int = 0; i < refCount; i++) {
            var data:ReferenceData = refs[i];
            var refImplClass:Class = _referenceClasses[data.tag];

            node._references[i] = new refImplClass(node, data.propertyName, data.referencePath);
        }
    }

    private static function initReferenceData(node:Node, className:String):Vector.<ReferenceData> {
        var refs:Vector.<ReferenceData> = _referenceData[className];

        // this class was already processed
        if(refs != null) return refs;

        _referenceData[className] = refs = new <ReferenceData>[];

        var type:XML = describeType(node);
        var metadataXML:XML, tag:String;

        // set variables references
        for each (var variableXML:XML in type.variable)
            for each(metadataXML in variableXML.metadata)
                for(tag in _referenceClasses)
                    if(metadataXML.@name == tag)
                        refs[refs.length] = new ReferenceData(variableXML.@name, metadataXML.arg.@value, tag);

        // set accessor references
        for each (var accessorXML:XML in type.accessor)
            for each(metadataXML in accessorXML.metadata)
                for(tag in _referenceClasses)
                    if(metadataXML.@name == tag)
                        refs[refs.length] = new ReferenceData(accessorXML.@name, metadataXML.arg.@value, tag);

        return refs;
    }
}
}

class ReferenceData {
    public var propertyName:String;
    public var referencePath:String;
    public var tag:String;

    public function ReferenceData(propertyName:String, referencePath:String, tag:String) {
        this.propertyName   = propertyName;
        this.referencePath  = referencePath;
        this.tag            = tag;
    }
}
