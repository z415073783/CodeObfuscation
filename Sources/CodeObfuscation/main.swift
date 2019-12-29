import Foundation
import MMScriptFramework
MMLOG.info("Hello, this is my world!")
MMLOG.info("工具所在目录 = \(kShellPath)")



ProcessInfo.processInfo.isHelp(helpStr: """
--------------------------代码混淆工具------------------------------
使用事项:
    本工具当前只实现了:对头文件和类名相同的类进行添加前缀,如果文件名和类名不同,则不会修改类名. 后续有时间的话再添加能够单独识别类名的功能
    
    
type     0 | 1 | 2     0:添加前缀, 1: 变更前缀(如果文件的前缀不存在,则主动添加前缀), 2: 添加垃圾代码(未实现)
needPreName   需要添加的前缀
orgPreName   "name1,name2,name3..."   当type=0 | 1时,必填  需要替换的前缀列表

changeFilePath   需要变更的文件(类)路径   即:修改changeFilePath目录下的文件会应用到rootPath目录下的所有文件信息
rootPath         修改范围路径
effectFileTypeList   "type1,type2,type3"   影响的文件类型列表   默认:\(kEffectFileTypeList)  只影响类型为h&m&mm&cpp&swift的文件
noChangePrefixList   过滤不用变更的文件前缀列表    默认:\(kNoChangePrefixList)
    
xcodeprojPath     工程配置文件路径(XXX.xcodeproj)

""")

let dictionary = ProcessInfo.processInfo.getDictionary()
guard let type = dictionary["type"], let needPreName = dictionary["needPreName"], let oriPreNameString = dictionary["oriPreName"], let changeFilePath = dictionary["changeFilePath"], let rootPath = dictionary["rootPath"] else {
    MMLOG.error("参数字段错误")
    exit(1)
}
let effectFileTypeListString = dictionary["effectFileTypeList"] ?? kEffectFileTypeList
let noChangePrefixListString = dictionary["noChangePrefixList"] ?? kNoChangePrefixList

let oriPreNameList: [String] = oriPreNameString.split(",") //原有文件可能有的前缀
let effectTypeList: [String] = effectFileTypeListString.split(",") //影响的文件类型
let noChangePrefixList: [String] = noChangePrefixListString.split(",") //需要过滤的前缀
MMLOG.info("传入参数: type = \(type), needPreName = \(needPreName), oriPreNameList = \(oriPreNameList), changeFilePath = \(changeFilePath), rootPath = \(rootPath)")


let changeFilePathList = FileControl.getFilePath(rootPath: changeFilePath, selectFile: "", isSuffix: false, onlyOne: false)

MMLOG.info("changeFilePathList.count = \(changeFilePathList.count)")

//只影响后缀名为.h&.m&.mm&.cpp&.swift的文件
class ChangeFileData {
    var oriName: String = ""
    var path: String = ""
    var newName: String = ""
    //初始化的三个参数必须存在
    init(oriName: String, path: String, newName: String) {
        self.oriName = oriName
        self.path = path
        self.newName = newName
    }
}
MMLOG.info("开始检查文件")
var needChangeFiles: [String: ChangeFileData] = [:]
var newFileNames: [String: ChangeFileData] = [:]
for item in changeFilePathList {
    //过滤不用变更前缀的文件名及前缀
    var isContinue = false
    for noChangePre in noChangePrefixList {
        if item.name.hasPrefix(noChangePre) {
            isContinue = true
        }
    }
    if isContinue == true {
        MMLOG.info("不需要变更的文件名字: \(item.name)")
        continue
    }
    
    //影响的文件类型
    for type in effectTypeList {
        if item.name.hasSuffix(".\(type)") {
            var oriName = item.name
            //去掉已有前缀
            for existPre in oriPreNameList {
//                oriName.hasPrefix(existPre)
                oriName = RegularFunc.replacePrefix(name: oriName, needRemovePrefix: existPre)
            }
          
            //添加新前缀
            var newName = needPreName + oriName
            
            if (newFileNames[newName] != nil) {
                newName = newName + "_" //新名字如果已存在, 则末尾追加下划线
            }
            if let existData = needChangeFiles[item.name] {
                MMLOG.error("需要修改的文件名字重复, 请检查 name = \(item.name); 1 = \(existData.path ?? ""); 2 = \(item.path)")
                exit(2)
            }
            
            let model = ChangeFileData(oriName: item.name, path: item.path, newName: newName)
            needChangeFiles[model.oriName] = model
            newFileNames[newName] = model
            MMLOG.info("需要变更的文件名 = \(model.oriName) 新名字: \(model.newName)")
            continue
        }
    }
}


//开始变更
MMLOG.info("开始变更文件")
//获取配置文件路径
var xcodeProjModel: ProjectPathModel?
if let xcodeprojPath = dictionary["xcodeprojPath"] {
    let resultList = FileControl.getFilePath(rootPath: xcodeprojPath, selectFile: "project.pbxproj", isSuffix: false, onlyOne: true)
    if resultList.count > 0 {
        xcodeProjModel = resultList.first
    }
}
//已变更名字列表 不包含.h或者.m等后缀

var changedNames: [String: String] = [:] //原有名字:新名字

for (key, model) in needChangeFiles {
    //变更自己的名字
    let result = MMScript.runScript(model: ScriptModel(path: kMVPath, arguments: [model.oriName, model.newName], scriptRunPath: model.path, showOutData: true))

    if result.status == false {
        //修改失败
        MMLOG.error("重命名失败,跳过\(model.oriName)")
        continue
    }
    
    
    //变更配置文件内容
    if let xcodeProjModel = xcodeProjModel {
        do {
            var projectContainer = try NSString(contentsOfFile: xcodeProjModel.fullPath(), encoding: String.Encoding.utf8.rawValue)
//            projectContainer
            MMLOG.info("配置文件变更: \(model.oriName) -> \(model.newName)")
            projectContainer = RegularFunc.checkAndReplace(container: projectContainer as String, oldName: model.oriName, newName: model.newName) as NSString
            try projectContainer.write(toFile: xcodeProjModel.fullPath(), atomically: true, encoding: String.Encoding.utf8.rawValue)
        } catch {
            MMLOG.error("配置文件读取失败 error = \(error)")
            exit(5)
        }
    }
    
    guard let old = model.oriName.split(".").first, let new = model.newName.split(".").first else {
        MMLOG.error("文件名称截取失败model.oriName = \(model.oriName), model.newName = \(model.newName)")
        exit(4)
    }
    
    
    if let existNew = changedNames[old] {
        if existNew != new {
            MMLOG.error("原有文件名已存在 old = \(old),但是新文件名不匹配 existNew = \(existNew), new = \(new)")
            exit(3)
        }
    } else {
        changedNames[old] = new
    }
}

//变更影响范围下的所有文件内容
MMLOG.info("开始变更影响范围")
//changedNames
//rootPath
let rootFilePathList = FileControl.getFilePath(rootPath: rootPath, selectFile: "", isSuffix: false, onlyOne: false)
for item in rootFilePathList {
    //过滤不用变更前缀的文件名及前缀
    //影响的文件类型
    for type in effectTypeList {
        if item.name.hasSuffix(".\(type)") {
            do {
                //            需要修改的文件
                var container = try NSString(contentsOfFile: item.fullPath(), encoding: String.Encoding.utf8.rawValue) as String
                
                for (old, new) in changedNames {
                    container = RegularFunc.replaceNewName(container: container, oldName: old, newName: new)
                }
                try (container as NSString).write(toFile: item.fullPath(), atomically: true, encoding: String.Encoding.utf8.rawValue)
            } catch {
                MMLOG.error("文件读取/写入错误 error = \(error)")
            }
            continue
        }
    }
}
MMLOG.info("任务结束!")


