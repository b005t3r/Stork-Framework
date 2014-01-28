/**
 * User: booster
 * Date: 27/01/14
 * Time: 14:39
 */
package stork.core.reference {
import org.flexunit.asserts.assertEquals;

import stork.core.SceneNode;
import stork.core.reference.test.PublicReferencedNode;

public class ReferenceTest {
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
    public function simpleLocalReferenceTest():void {
        var referencing:SimpleLocalReferencingNode = new SimpleLocalReferencingNode();
        var referenced:ReferencedNode = new ReferencedNode("mySibling");
        var publicReferenced:PublicReferencedNode = new PublicReferencedNode(); // has to be public, so its class can be referenced

        assertEquals(referencing.refName, null);
        assertEquals(referencing.refClass, null);

        scene.addNode(referencing);

        assertEquals(referencing.refName, null);
        assertEquals(referencing.refClass, null);

        scene.addNode(referenced);

        assertEquals(referencing.refName, referenced);
        assertEquals(referencing.refClass, null);

        referenced.removeFromParent();

        assertEquals(referencing.refName, null);
        assertEquals(referencing.refClass, null);

        scene.addNode(referenced);

        assertEquals(referencing.refName, referenced);
        assertEquals(referencing.refClass, null);

        referencing.removeFromParent();

        assertEquals(referencing.refName, null);
        assertEquals(referencing.refClass, null);

        scene.addNode(publicReferenced);
        scene.addNode(referencing);

        assertEquals(referencing.refName, referenced);
        assertEquals(referencing.refClass, publicReferenced);

        publicReferenced.removeFromParent();

        assertEquals(referencing.refName, referenced);
        assertEquals(referencing.refClass, null);

        scene.addNode(publicReferenced);
        referenced.removeFromParent();

        assertEquals(referencing.refName, null);
        assertEquals(referencing.refClass, publicReferenced);
    }

    [Test]
    public function simpleGlobalReferenceTest():void {
        var referencing:SimpleGlobalReferencingNode = new SimpleGlobalReferencingNode();
        var referenced:ReferencedNode = new ReferencedNode("mySibling");
        var publicReferenced:PublicReferencedNode = new PublicReferencedNode();

        assertEquals(referencing.refName, null);
        assertEquals(referencing.refClass, null);

        scene.addNode(referencing);

        assertEquals(referencing.refName, null);
        assertEquals(referencing.refClass, null);

        scene.addNode(referenced);

        assertEquals(referencing.refName, referenced);
        assertEquals(referencing.refClass, null);

        referenced.removeFromParent();

        assertEquals(referencing.refName, null);
        assertEquals(referencing.refClass, null);

        scene.addNode(referenced);

        assertEquals(referencing.refName, referenced);
        assertEquals(referencing.refClass, null);

        referencing.removeFromParent();

        assertEquals(referencing.refName, null);
        assertEquals(referencing.refClass, null);

        scene.addNode(publicReferenced);
        scene.addNode(referencing);

        assertEquals(referencing.refName, referenced);
        assertEquals(referencing.refClass, publicReferenced);

        publicReferenced.removeFromParent();

        assertEquals(referencing.refName, referenced);
        assertEquals(referencing.refClass, null);

        scene.addNode(publicReferenced);
        referenced.removeFromParent();

        assertEquals(referencing.refName, null);
        assertEquals(referencing.refClass, publicReferenced);
    }
}
}

import stork.core.Node;
import stork.core.reference.test.PublicReferencedNode;

class SimpleLocalReferencingNode extends Node {
    [LocalReference("mySibling")]
    public var refName:ReferencedNode;

    private var _refClass:PublicReferencedNode;

    [LocalReference("@stork.core.reference.test::PublicReferencedNode")]
    public function get refClass():PublicReferencedNode { return _refClass; }
    public function set refClass(value:PublicReferencedNode):void { _refClass = value; }
}

class SimpleGlobalReferencingNode extends Node {
    private var _refName:ReferencedNode;

    [GlobalReference("@stork.core.reference.test::PublicReferencedNode")]
    public var refClass:PublicReferencedNode;

    [GlobalReference("mySibling")]
    public function get refName():ReferencedNode { return _refName; }
    public function set refName(value:ReferencedNode):void { _refName = value; }
}

class ReferencedNode extends Node {
    public function ReferencedNode(name:String) {
        super(name);
    }
}
