## 归并排序
24.7.2 update  

实现过程:

                              [0,8]
  			 [9, 8, 7, 6, 5, 4, 3, 2, 1]                                      
				/             \
                             [0,4]           [5,8]
		      [9, 8, 7, 6, 5]    [4, 3, 2, 1]    	      -                            
			/      \           /       \
                     [0,2]     [3,4]    [5,6]     [7,8]
		  [9, 8, 7]  [6, 5]    [4, 3]     [2, 1]       
		    /  \      /  \       /  \      /    \
                [0,1] [2,2] [3,3][4,4][5,5][6,6][7,7] [8,8]
		[9, 8]  [7]  [6]   [5]  [5] [6]  [2]   [1]     
		 /  \                 
              [0,0] [1,1]
               [9]   [8]	
		\    /
		[8, 9]	

		[7, 8, 9] [5, 6]

		[5, 6, 7, 8, 9]	[1, 2, 3, 4]

		[1, 2, 3, 4, 5, 6, 7, 8, 9]	

代码实现：

```c
package sortdemo;

import java.util.Arrays;

/**
 * Created by chengxiao on 2016/12/8.
 */
public class MergeSort {
    public static void main(String []args){
        int []arr = {9,8,7,6,5,4,3,2,1};
        sort(arr);
        System.out.println(Arrays.toString(arr));
    }
    public static void sort(int []arr){
        int []temp = new int[arr.length];//在排序前，先建好一个长度等于原数组长度的临时数组，避免递归中频繁开辟空间
        sort(arr,0,arr.length-1,temp);
    }
    private static void sort(int[] arr,int left,int right,int []temp){
        if(left<right){
            int mid = (left+right)/2;
            sort(arr,left,mid,temp);//左边归并排序，使得左子序列有序
            sort(arr,mid+1,right,temp);//右边归并排序，使得右子序列有序
            merge(arr,left,mid,right,temp);//将两个有序子数组合并操作
        }
    }
    private static void merge(int[] arr,int left,int mid,int right,int[] temp){
        int i = left;//左序列指针
        int j = mid+1;//右序列指针
        int t = 0;//临时数组指针
        while (i<=mid && j<=right){
            if(arr[i]<=arr[j]){
                temp[t++] = arr[i++];
            }else {
                temp[t++] = arr[j++];
            }
        }
        while(i<=mid){//将左边剩余元素填充进temp中
            temp[t++] = arr[i++];
        }
        while(j<=right){//将右序列剩余元素填充进temp中
            temp[t++] = arr[j++];
        }
        t = 0;
        //将temp中的元素全部拷贝到原数组中
        while(left <= right){
            arr[left++] = temp[t++];
        }
    }
}
```

参考链接：https://www.cnblogs.com/chengxiao/p/6194356.html


