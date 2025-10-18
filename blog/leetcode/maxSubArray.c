int maxSubArray(int* nums, int numsSize) {
    int maxi = nums[0], max_cur = nums[0];
    for(int i = 1; i < numsSize; i++) {
        // invariant : max_cur est la somme consécutive max qui se termine en i
        max_cur = max_cur + nums[i];
        if(max_cur < nums[i])
            max_cur = nums[i];
        if(max_cur > maxi)
            maxi = max_cur;
    }
    return maxi;
}