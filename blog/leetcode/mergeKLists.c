struct ListNode {
    int val;
    struct ListNode *next;
};

 struct ListNode* mergeTwoLists(struct ListNode* list1, struct ListNode* list2) {
    if (list1 == NULL) return list2;
    if (list2 == NULL) return list1;
    if (list1->val <= list2->val) {
        list1->next = mergeTwoLists(list1->next, list2);
        return list1;
    }
    if (list1->val > list2->val) {
        list2->next = mergeTwoLists(list1, list2->next);
        return list2;
    }
    return NULL;
}

struct ListNode* mergeKLists(struct ListNode** lists, int listsSize) {
    if (listsSize == 0) return NULL;
    int n = 0;
    while (listsSize > 1) {
        for (int i = 0; i < listsSize/2; i++) {
            lists[2*i] = mergeTwoLists(lists[2*i], lists[2*i + 1]);
        }
        if (listsSize % 2 == 1) {
            lists[listsSize/2 + 1] = lists[listsSize - 1];
            listsSize++;
        }
        listsSize /= 2;
        printf("%d\n", listsSize);
        n++;
        if (n > 5) break;
    }
    return lists[0];
}

int main() {
    [[1,4,5],[1,3,4],[2,6]]
}