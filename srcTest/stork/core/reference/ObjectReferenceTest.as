/**
 * User: booster
 * Date: 03/02/14
 * Time: 15:27
 */
package stork.core.reference {
import flash.geom.Matrix;

import org.flexunit.asserts.assertEquals;

import stork.core.SceneNode;

public class ObjectReferenceTest {
    private var scene:SceneNode;

    [Before]
    public function setUp():void {
        scene = new SceneNode();
    }

    [After]
    public function tearDown():void {
        scene = null;
    }

    [Test]
    public function objectReferenceTest():void {
        var referencing:SimpleObjectReferencingNode = new SimpleObjectReferencingNode();

        var refByName:Object    = { "property" : "value" };
        var refByClass:Matrix   = new Matrix();

        assertEquals(referencing.refName, null);
        assertEquals(referencing.refClass, null);

        scene.addNode(referencing);

        assertEquals(referencing.refName, null);
        assertEquals(referencing.refClass, null);

        scene.addObject(refByName, "myObject");

        assertEquals(referencing.refName, refByName);
        assertEquals(referencing.refClass, null);

        scene.removeObject(refByName);

        assertEquals(referencing.refName, null);
        assertEquals(referencing.refClass, null);

        scene.addObject(refByName, "myObject");

        assertEquals(referencing.refName, refByName);
        assertEquals(referencing.refClass, null);

        referencing.removeFromParent();

        assertEquals(referencing.refName, null);
        assertEquals(referencing.refClass, null);

        scene.addObject(refByClass);
        scene.addNode(referencing);

        assertEquals(referencing.refName, refByName);
        assertEquals(referencing.refClass, refByClass);

        scene.removeObject(refByClass);

        assertEquals(referencing.refName, refByName);
        assertEquals(referencing.refClass, null);

        scene.addObject(refByClass);
        scene.removeObject(refByName);

        assertEquals(referencing.refName, null);
        assertEquals(referencing.refClass, refByClass);
    }
}
}

import flash.geom.Matrix;

import stork.core.Node;

class SimpleObjectReferencingNode extends Node {
    private var _refName:Object;

    [ObjectReference("@flash.geom::Matrix")]
    public var refClass:Matrix;

    [ObjectReference("myObject")]
    public function get refName():Object { return _refName; }
    public function set refName(value:Object):void { _refName = value; }
}
