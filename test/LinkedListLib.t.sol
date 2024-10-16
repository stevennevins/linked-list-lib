// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {LinkedListLib} from "../src/LinkedListLib.sol";

contract LinkedListLibSetup is Test {
    LinkedListLib.LinkedList internal list;
}

contract Insert is LinkedListLibSetup {
    using LinkedListLib for LinkedListLib.LinkedList;

    function testInsertIntoEmptyList() public {
        uint256 nodeIndex = list.insert(5);
        assertTrue(list.contains(5));
        assertEq(list.getSize(), 1);
        assertEq(nodeIndex, 1);
    }

    function testInsertAtBeginning() public {
        list.insert(5);
        uint256 nodeIndex = list.insert(3);
        assertTrue(list.contains(3));
        assertEq(list.getSize(), 2);
        assertEq(nodeIndex, 2);
    }

    function testInsertInMiddle() public {
        list.insert(3);
        list.insert(5);
        uint256 nodeIndex = list.insert(4);
        assertTrue(list.contains(4));
        assertEq(list.getSize(), 3);
        assertEq(nodeIndex, 3);
    }

    function testInsertAtEnd() public {
        list.insert(3);
        list.insert(4);
        list.insert(5);
        uint256 nodeIndex = list.insert(6);
        assertTrue(list.contains(6));
        assertEq(list.getSize(), 4);
        assertEq(nodeIndex, 4);
    }

    function testInsertDuplicateValue() public {
        list.insert(3);
        list.insert(4);
        list.insert(5);
        uint256 nodeIndex = list.insert(4);
        assertEq(list.getSize(), 4);
        assertEq(nodeIndex, 4);
    }

    function testInsertMaintainsOrder() public {
        list.insert(5);
        list.insert(3);
        list.insert(7);
        list.insert(1);
        list.insert(9);

        uint256[] memory expectedOrder = new uint256[](5);
        expectedOrder[0] = 1;
        expectedOrder[1] = 3;
        expectedOrder[2] = 5;
        expectedOrder[3] = 7;
        expectedOrder[4] = 9;

        uint256 currentNode = list.head;
        for (uint256 i = 0; i < 5; i++) {
            assertEq(
                list.nodes[currentNode].data,
                expectedOrder[i],
                "Order is not maintained after insertion"
            );
            currentNode = list.nodes[currentNode].next;
        }
    }

    function testInsertDuplicateValueOrder() public {
        list.insert(3);
        list.insert(5);
        list.insert(7);
        list.insert(5);

        uint256[] memory expectedOrder = new uint256[](4);
        expectedOrder[0] = 3;
        expectedOrder[1] = 5;
        expectedOrder[2] = 5;
        expectedOrder[3] = 7;

        uint256 currentNode = list.head;
        for (uint256 i = 0; i < 4; i++) {
            assertEq(
                list.nodes[currentNode].data,
                expectedOrder[i],
                "Duplicate value not inserted in correct order"
            );
            currentNode = list.nodes[currentNode].next;
        }

        assertEq(list.getSize(), 4, "List size incorrect after inserting duplicate");
    }

    function testInsertZeroReverts() public {
        vm.expectRevert(LinkedListLib.DataMustBeGreaterThanZero.selector);
        list.insert(0);
    }
}

contract Remove is LinkedListLibSetup {
    using LinkedListLib for LinkedListLib.LinkedList;

    function testRemoveExistingElement() public {
        list.insert(3);
        uint256 node2 = list.insert(5);
        list.insert(7);

        list.remove(node2);
        assertFalse(list.contains(5));
        assertEq(list.getSize(), 2);
    }

    function testRemoveNonExistingElement() public {
        list.insert(3);
        list.insert(5);

        vm.expectRevert(LinkedListLib.InvalidNodeIndex.selector);
        list.remove(3); // Node index 3 doesn't exist
        assertEq(list.getSize(), 2);
    }

    function testRemoveMaintainsOrder() public {
        list.insert(1);
        list.insert(3);
        uint256 nodeToRemove = list.insert(5);
        list.insert(7);
        list.insert(9);

        list.remove(nodeToRemove);

        uint256[] memory expectedOrder = new uint256[](4);
        expectedOrder[0] = 1;
        expectedOrder[1] = 3;
        expectedOrder[2] = 7;
        expectedOrder[3] = 9;

        uint256 currentNode = list.head;
        for (uint256 i = 0; i < 4; i++) {
            assertEq(
                list.nodes[currentNode].data,
                expectedOrder[i],
                "Order is not maintained after removal"
            );
            currentNode = list.nodes[currentNode].next;
        }
    }

    function testRemoveFromEmptyList() public {
        vm.expectRevert(LinkedListLib.LinkedListIsEmpty.selector);
        list.remove(1);
    }

    function testRemoveInvalidNodeIndex() public {
        list.insert(3);
        vm.expectRevert(LinkedListLib.InvalidNodeIndex.selector);
        list.remove(0);
    }

    function testRemoveLastRemainingElements() public {
        uint256 node1 = list.insert(3);
        uint256 node2 = list.insert(7);

        list.remove(node1);
        list.remove(node2);

        assertTrue(list.isEmpty());
    }

    function testRemoveDuplicateValues() public {
        list.insert(3);
        uint256 node2 = list.insert(5);
        uint256 node3 = list.insert(5);
        list.insert(7);

        list.remove(node2);
        assertTrue(list.contains(5));
        assertEq(list.getSize(), 3);

        list.remove(node3);
        assertFalse(list.contains(5));
        assertEq(list.getSize(), 2);
    }
}

contract Contains is LinkedListLibSetup {
    using LinkedListLib for LinkedListLib.LinkedList;

    function testContainsEmptyList() public view {
        assertFalse(list.contains(1), "Empty list should not contain any element");
    }

    function testContainsExistingElements() public {
        list.insert(3);
        list.insert(5);
        list.insert(7);

        assertTrue(list.contains(3), "List should contain 3");
        assertTrue(list.contains(5), "List should contain 5");
        assertTrue(list.contains(7), "List should contain 7");
    }

    function testContainsNonExistingElement() public {
        list.insert(3);
        list.insert(5);
        list.insert(7);

        assertFalse(list.contains(4), "List should not contain 4");
    }

    function testContainsAfterRemoval() public {
        list.insert(3);
        uint256 nodeToRemove = list.insert(5);
        list.insert(7);

        list.remove(nodeToRemove);
        assertFalse(list.contains(5), "List should not contain 5 after removal");
        assertTrue(list.contains(3), "List should still contain 3 after removal of 5");
        assertTrue(list.contains(7), "List should still contain 7 after removal of 5");
    }

    function testContainsZeroReverts() public {
        vm.expectRevert(LinkedListLib.DataMustBeGreaterThanZero.selector);
        list.contains(0);
    }
}

contract GetSize is LinkedListLibSetup {
    using LinkedListLib for LinkedListLib.LinkedList;

    function testGetSizeEmptyList() public view {
        assertEq(list.getSize(), 0, "Empty list should have size 0");
    }

    function testGetSizeAfterInsertingOneElement() public {
        list.insert(3);
        assertEq(list.getSize(), 1, "List should have size 1 after inserting one element");
    }

    function testGetSizeAfterInsertingThreeElements() public {
        list.insert(3);
        list.insert(5);
        list.insert(7);
        assertEq(list.getSize(), 3, "List should have size 3 after inserting three elements");
    }

    function testGetSizeAfterRemovingOneElement() public {
        list.insert(3);
        uint256 nodeToRemove = list.insert(5);
        list.insert(7);
        list.remove(nodeToRemove);
        assertEq(list.getSize(), 2, "List should have size 2 after removing one element");
    }

    function testGetSizeAfterRemovingAllElements() public {
        uint256 node1 = list.insert(3);
        uint256 node2 = list.insert(5);
        uint256 node3 = list.insert(7);
        list.remove(node1);
        list.remove(node2);
        list.remove(node3);
        assertEq(list.getSize(), 0, "List should have size 0 after removing all elements");
    }
}

contract IsEmpty is LinkedListLibSetup {
    using LinkedListLib for LinkedListLib.LinkedList;

    function testIsEmptyNewList() public view {
        assertTrue(list.isEmpty(), "New list should be empty");
    }

    function testIsEmptyAfterInsertion() public {
        list.insert(5);
        assertFalse(list.isEmpty(), "List with an element should not be empty");
    }

    function testIsEmptyAfterRemoval() public {
        uint256 nodeToRemove = list.insert(5);
        list.remove(nodeToRemove);
        assertTrue(list.isEmpty(), "List should be empty after removing all elements");
    }

    function testIsEmptyWithMultipleInsertions() public {
        list.insert(3);
        list.insert(7);
        assertFalse(list.isEmpty(), "List with multiple elements should not be empty");
    }

    function testIsEmptyAfterPartialRemoval() public {
        uint256 node1 = list.insert(3);
        list.insert(7);
        list.remove(node1);
        assertFalse(list.isEmpty(), "List should not be empty after partial removal");
    }

    function testIsEmptyAfterRemovingAllElements() public {
        uint256 node1 = list.insert(3);
        uint256 node2 = list.insert(7);
        list.remove(node1);
        list.remove(node2);
        assertTrue(list.isEmpty(), "List should be empty after removing all elements");
    }
}
