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
    private static var _referenceClasses:Dictionary     = new Dictionary(); // referenceTag -> referenceImplClass
    private static var _referenceData:Dictionary        = new Dictionary(); // nodeClassName -> Vector.<ReferenceData>
    private static var _referenceHandlerData:Dictionary = new Dictionary(); // nodeClassName -> Vector.<ReferenceHandlerData>

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

        var className:String = getQualifiedClassName(node);

        initReferenceData(node, className);

        var refHandlers:Vector.<ReferenceHandlerData>   = _referenceHandlerData[className];
        var refHandlerCount:int                         = refHandlers.length;
        var refs:Vector.<ReferenceData>                 = _referenceData[className];
        var refCount:int                                = refs.length;

        if(refHandlerCount != 0) {
            node._referenceHandlers = new Vector.<ReferenceHandler>(refHandlerCount, true);

            for(var i:int = 0; i < refHandlerCount; ++i) {
                var refHandlerData:ReferenceHandlerData = refHandlers[i];

                node._referenceHandlers[i] = new ReferenceHandler(node[refHandlerData.methodName], refHandlerData.propertyNames);
            }
        }

        if(refCount != 0) {
            node._references = new Vector.<Reference>(refCount, true);

            for(var j:int = 0; j < refCount; ++j) {
                var refData:ReferenceData = refs[j];
                var refImplClass:Class = _referenceClasses[refData.tag];

                node._references[j] = new refImplClass(node, refData.propertyName, refData.referencePath);
            }
        }
    }

    private static function initReferenceData(node:Node, className:String):void {
        var refs:Vector.<ReferenceData> = _referenceData[className];
        var refHandlers:Vector.<ReferenceHandlerData> = _referenceHandlerData[className];

        // this class was already processed
        if(refs != null || refHandlers != null) return;

        _referenceHandlerData[className] = refHandlers = new <ReferenceHandlerData>[];
        _referenceData[className] = refs = new <ReferenceData>[];

        var typeXML:XML = describeType(node);
        var metadataXML:XML, tag:String;

        // set reference handlers
        for each (var methodXML:XML in typeXML.method)
            for each(metadataXML in methodXML.metadata)
                if(metadataXML.@name == ReferenceHandler.TAG_NAME)
                    refHandlers[refHandlers.length] = new ReferenceHandlerData(methodXML.@name, metadataXML.arg.@value);

        // set variables references
        for each (var variableXML:XML in typeXML.variable)
            for each(metadataXML in variableXML.metadata)
                for(tag in _referenceClasses)
                    if(metadataXML.@name == tag)
                        refs[refs.length] = new ReferenceData(variableXML.@name, metadataXML.arg.@value, tag);

        // set accessor references
        for each (var accessorXML:XML in typeXML.accessor)
            for each(metadataXML in accessorXML.metadata)
                for(tag in _referenceClasses)
                    if(metadataXML.@name == tag)
                        refs[refs.length] = new ReferenceData(accessorXML.@name, metadataXML.arg.@value, tag);
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

class ReferenceHandlerData {
    private static const replaceWhitespaces:RegExp = /[\s\r\n]+/gim;

    public var methodName:String;
    public var propertyNames:Vector.<String>;

    public function ReferenceHandlerData(methodName:String, properyNames:String) {
        this.methodName = methodName;
        this.propertyNames = new <String>[];

        var names:Array = properyNames.split(",");
        var count:int = names.length;
        for(var i:int = 0; i < count; ++i)
            this.propertyNames[i] = String(names[i]).replace(ReferenceHandlerData.replaceWhitespaces, "");
    }
}