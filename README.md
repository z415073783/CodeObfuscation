# CodeObfuscation
用于给工程内的文件添加/替换前缀的工具  当前只实现了替换文件名和与文件名相同的类名, 之后有时间会增加类名单独识别并替换的功能

使用方法: 用xcode将工程编译后, 找到生成的工具,使用命令行调用 ./CodeObfuscation -h 可查看具体使用方法



type     0 | 1 | 2     0:添加前缀, 1: 变更前缀(如果文件的前缀不存在,则主动添加前缀), 2: 添加垃圾代码(未实现)
needPreName   需要添加的前缀
orgPreName   "name1,name2,name3..."   当type=0 | 1时,必填  需要替换的前缀列表

changeFilePath   需要变更的文件(类)路径   即:修改changeFilePath目录下的文件会应用到rootPath目录下的所有文件信息
rootPath         修改范围路径
effectFileTypeList   "type1,type2,type3"   影响的文件类型列表   默认:h,m,mm,cpp,swift,storyboard,xib  只影响类型为h&m&mm&cpp&swift的文件
noChangePrefixList   过滤不用变更的文件前缀列表    默认:AppDelegate,main,UI,NS,CA,GL,Main.storyboard,LaunchScreen.storyboard

xcodeprojPath     工程配置文件路径(XXX.xcodeproj)
