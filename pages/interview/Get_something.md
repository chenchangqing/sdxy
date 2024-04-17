# 取东西

[测试一下](http://www.1221.site/mianshi.html)

```javascript
<html>
<head>
<script type="text/javascript">

// 初始化每行数量
var row1Count = 3;
var row2Count = 5;
var row3Count = 7;

// 获取行剩余数量
function getRemainCount(rowNum) {
    switch(parseInt(rowNum))
    {
    case 1:
        return row1Count;
    case 2:
        return row2Count;
    case 3: 
        return row3Count;
    default:
        return 0;
    }
}

// 更新行数量
// rowNum: 第几行（1,2,3）
// getCount: 取数量
function updateRemainCount(rowNum, getCount) {
    switch(parseInt(rowNum))
    {
    case 1:
        row1Count -= getCount;
        break;
    case 2:
        row2Count -= getCount;
        break;
    case 3: 
        row3Count -= getCount;
        break;
    default:
        break;
    }
};

// 判断是否取完所有
function judgeFinish() {
	return (row1Count + row2Count + row3Count) <= 0;
};

// 取东西
// rowNum: 第几行（1,2,3）
// getCount: 取数量
// 返回值 0:成功取出 -1:你是输家，-2:第x行空，-3:第x行数量不足
function getThing(rowNum, getCount) {
    var remainCount = getRemainCount(rowNum);
    if (remainCount > 0) {
        if (getCount > remainCount) {
            return -3;// 第x行数量不足
        } else {
		    // 更新行数量
            updateRemainCount(rowNum, getCount);
            // 判断是否取完
            if (judgeFinish()) {
                return -1;// 你是输家
            }
            return 0;// 成功取出
        }
	} else {
        return -2;// 第x行空
    }
}

// 执行回合
// getCount: 取数量
// rowNum: 第几行（1,2,3）
function round(rowNum, getCount) {
    var result = getThing(rowNum, getCount);
    switch(result)
    {
    case 0: 
        alert("成功取出");
        break;
    case -1: 
        alert("你是输家");
        break;
    case -2: 
        alert("第"+rowNum+"行空");
        break;
    case -3:
        alert("第"+rowNum+"行数量不足");
        break;
    default:
        break;
    }
};

// 运行
function run() {
    var rowNum = prompt("取第几行:","");
    var getCount = prompt("取多少:","");
    round(rowNum, getCount);
}
</script>
</head>
<body>

15个任意物品（可以是火柴牙签poker）

以下按牙签为例

将15根牙签

分成三行

每行自上而下（其实方向不限）分别是3、5、7根

安排两个玩家，每人可以在一轮内，在任意行拿任意根牙签，但不能跨行

拿最后一根牙签的人即为输家

题目

请用你最擅长的语言，以你觉得最优雅的方式写一个符合以上游戏规则的程序。完成后把写好的代码和简历同时发到以下邮箱（备注姓名+岗位），并加上一段简短的文字描述一下你的想法

（请使用javascript，typescript或C#的其中一种语言完成测试题）
<br/>
<br/>
<input type="button" onclick="run()" value="取东西" />

</body>
</html>
```