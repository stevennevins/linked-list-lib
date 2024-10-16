// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library LinkedListLib {
    error DataMustBeGreaterThanZero();
    error LinkedListIsEmpty();
    error InvalidNodeIndex();

    struct Node {
        uint256 data;
        uint256 next;
    }

    struct LinkedList {
        uint256 head;
        uint256 tail;
        uint256 size;
        mapping(uint256 => Node) nodes;
    }

    function insert(LinkedList storage self, uint256 data) internal returns (uint256) {
        if (data == 0) {
            revert DataMustBeGreaterThanZero();
        }

        uint256 newNodeIndex = self.size + 1;
        self.nodes[newNodeIndex] = Node(data, 0);

        if (self.size == 0) {
            self.head = newNodeIndex;
            self.tail = newNodeIndex;
        } else {
            uint256 currentIndex = self.head;
            uint256 previousIndex = 0;

            while (currentIndex != 0 && self.nodes[currentIndex].data <= data) {
                previousIndex = currentIndex;
                currentIndex = self.nodes[currentIndex].next;
            }

            if (previousIndex == 0) {
                self.nodes[newNodeIndex].next = self.head;
                self.head = newNodeIndex;
            } else {
                self.nodes[newNodeIndex].next = self.nodes[previousIndex].next;
                self.nodes[previousIndex].next = newNodeIndex;

                if (previousIndex == self.tail) {
                    self.tail = newNodeIndex;
                }
            }
        }

        self.size++;
        return newNodeIndex;
    }

    function remove(LinkedList storage self, uint256 nodeIndex) internal {
        if (self.head == 0) {
            revert LinkedListIsEmpty();
        }
        if (nodeIndex == 0) {
            revert InvalidNodeIndex();
        }

        uint256 currentIndex = self.head;
        uint256 previousIndex = 0;

        while (currentIndex != 0 && currentIndex != nodeIndex) {
            previousIndex = currentIndex;
            currentIndex = self.nodes[currentIndex].next;
        }

        if (currentIndex == 0) {
            revert InvalidNodeIndex();
        }

        if (previousIndex == 0) {
            self.head = self.nodes[currentIndex].next;
        } else {
            self.nodes[previousIndex].next = self.nodes[currentIndex].next;
        }

        if (currentIndex == self.tail) {
            self.tail = previousIndex;
        }

        delete self.nodes[currentIndex];
        self.size--;
    }

    function contains(LinkedList storage self, uint256 data) internal view returns (bool) {
        if (data == 0) {
            revert DataMustBeGreaterThanZero();
        }

        uint256 currentIndex = self.head;

        while (currentIndex != 0) {
            if (self.nodes[currentIndex].data == data) {
                return true;
            }
            currentIndex = self.nodes[currentIndex].next;
        }

        return false;
    }

    function getSize(
        LinkedList storage self
    ) internal view returns (uint256) {
        return self.size;
    }

    function isEmpty(
        LinkedList storage self
    ) internal view returns (bool) {
        return self.head == 0;
    }
}
