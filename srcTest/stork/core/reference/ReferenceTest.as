/**
 * User: booster
 * Date: 27/01/14
 * Time: 14:39
 */
package stork.core.reference {
import org.flexunit.asserts.assertEquals;

import stork.core.ContainerNode;

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

    [Test]
    public function complexReferenceTest():void {
        var container:ContainerNode = new ContainerNode("Container");
        var globalContainer:ContainerNode = new ContainerNode("GlobalContainer");
        var mySibling:ReferencedNode = new ReferencedNode("mySibling");

        var complexContainer:ContainerNode = new ContainerNode();
        var complexNode:ComplexReferencingNode = new ComplexReferencingNode();

        var siblingContainer:ContainerNode = new ContainerNode("SiblingContainer");
        var localContainer:ContainerNode = new ContainerNode("LocalContainer");
        var publicRefNode:PublicReferencedNode = new PublicReferencedNode();

        scene.addNode(container);
        container.addNode(globalContainer);
        globalContainer.addNode(mySibling);

        scene.addNode(complexContainer);
        complexContainer.addNode(complexNode);
        complexContainer.addNode(siblingContainer);
        siblingContainer.addNode(localContainer);
        siblingContainer.addNode(publicRefNode);

        assertEquals(complexNode.globCont, globalContainer);
        assertEquals(complexNode.locCont, localContainer);
        assertEquals(complexNode.ref, mySibling);
        assertEquals(complexNode.pubRef, publicRefNode);

        var anotherContainer:ContainerNode = new ContainerNode("Container");
        var anotherGlobalContainer:ContainerNode = new ContainerNode("GlobalContainer");
        var anotherMySibling:ReferencedNode = new ReferencedNode("mySibling");

        scene.addNode(anotherContainer);
        anotherContainer.addNode(anotherGlobalContainer);
        anotherGlobalContainer.addNode(anotherMySibling);

        assertEquals(complexNode.globCont, globalContainer);
        assertEquals(complexNode.locCont, localContainer);
        assertEquals(complexNode.ref, mySibling);
        assertEquals(complexNode.pubRef, publicRefNode);

        container.removeFromParent();

        assertEquals(complexNode.globCont, anotherGlobalContainer);
        assertEquals(complexNode.locCont, localContainer);
        assertEquals(complexNode.ref, anotherMySibling);
        assertEquals(complexNode.pubRef, publicRefNode);

        scene.addNode(container);

        assertEquals(complexNode.globCont, anotherGlobalContainer);
        assertEquals(complexNode.locCont, localContainer);
        assertEquals(complexNode.ref, anotherMySibling);
        assertEquals(complexNode.pubRef, publicRefNode);

        container.removeFromParent();

        assertEquals(complexNode.globCont, anotherGlobalContainer);
        assertEquals(complexNode.locCont, localContainer);
        assertEquals(complexNode.ref, anotherMySibling);
        assertEquals(complexNode.pubRef, publicRefNode);

        scene.addNode(container);

        assertEquals(complexNode.globCont, anotherGlobalContainer);
        assertEquals(complexNode.locCont, localContainer);
        assertEquals(complexNode.ref, anotherMySibling);
        assertEquals(complexNode.pubRef, publicRefNode);

        scene.addNode(container);

        assertEquals(complexNode.globCont, anotherGlobalContainer);
        assertEquals(complexNode.locCont, localContainer);
        assertEquals(complexNode.ref, anotherMySibling);
        assertEquals(complexNode.pubRef, publicRefNode);

        anotherContainer.removeFromParent();

        assertEquals(complexNode.globCont, globalContainer);
        assertEquals(complexNode.locCont, localContainer);
        assertEquals(complexNode.ref, mySibling);
        assertEquals(complexNode.pubRef, publicRefNode);

        scene.addNode(anotherContainer);

        assertEquals(complexNode.globCont, globalContainer);
        assertEquals(complexNode.locCont, localContainer);
        assertEquals(complexNode.ref, mySibling);
        assertEquals(complexNode.pubRef, publicRefNode);

        scene.addNode(container);

        assertEquals(complexNode.globCont, globalContainer);
        assertEquals(complexNode.locCont, localContainer);
        assertEquals(complexNode.ref, mySibling);
        assertEquals(complexNode.pubRef, publicRefNode);

        var anotherSiblingContainer:ContainerNode = new ContainerNode("SiblingContainer");
        var anotherLocalContainer:ContainerNode = new ContainerNode("LocalContainer");
        var anotherPublicRefNode:PublicReferencedNode = new PublicReferencedNode();

        complexContainer.addNode(anotherSiblingContainer);
        anotherSiblingContainer.addNode(anotherLocalContainer);
        anotherSiblingContainer.addNode(anotherPublicRefNode);

        assertEquals(complexNode.globCont, globalContainer);
        assertEquals(complexNode.locCont, localContainer);
        assertEquals(complexNode.ref, mySibling);
        assertEquals(complexNode.pubRef, publicRefNode);

        siblingContainer.removeFromParent();

        assertEquals(complexNode.globCont, globalContainer);
        assertEquals(complexNode.locCont, anotherLocalContainer);
        assertEquals(complexNode.ref, mySibling);
        assertEquals(complexNode.pubRef, anotherPublicRefNode);
    }
}
}

import stork.core.ContainerNode;
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

class ComplexReferencingNode extends Node {
    [GlobalReference("Container/GlobalContainer")]
    public var globCont:ContainerNode;

    [LocalReference("SiblingContainer/LocalContainer")]
    public var locCont:ContainerNode;

    [GlobalReference("Container/@stork.core::ContainerNode/mySibling")]
    public var ref:ReferencedNode;

    [LocalReference("@stork.core::ContainerNode/@stork.core.reference.test::PublicReferencedNode")]
    public var pubRef:PublicReferencedNode;
}

class ReferencedNode extends Node {
    public function ReferencedNode(name:String) {
        super(name);
    }
}
