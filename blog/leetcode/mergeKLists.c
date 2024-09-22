/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     struct ListNode *next;
 * };
 */
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

struct ListNode* merge(struct ListNode** lists, int i, int j) {
    if(i + 1 == j) return lists[i];
    if(i == j) return NULL;
    
    int m = (i + j)/2;
    return mergeTwoLists(merge(lists, i, m), merge(lists, m, j));
}

struct ListNode* mergeKLists(struct ListNode** lists, int listsSize) {
    return merge(lists, 0, listsSize);
}
