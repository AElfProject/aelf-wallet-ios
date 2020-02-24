## 查看项目目录结构

安装tree命令

`brew install tree`

查看目录

`tree -a`

忽略某个文件夹(注意要带引号,支持正则表达式)

`tree -a -I "foldername"`

列出目录，忽略.git文件夹，输出到tree.md

`tree -a -I ".git" >> tree.md`

显示文件夹的层级（n表示层级数）

`tree -L n`

```
├── Classes
│   ├── AppDelegate	# 启动入口
│   ├── Base		# 基类
│   ├── Common		# 通用
│   ├── Extensions	# 扩展
│   ├── Libs		# 第三方
│   ├── Utility		# 工具类
│   ├── Modules		# 业务模块
│	 	├── Assets	# 资产
│   	├── Discover# 发现
│   	├── Market	# 行情
│   	├── Setting	# 设置
│   	└── Wallet	# 钱包
└── Resource		# 资源文件
```
