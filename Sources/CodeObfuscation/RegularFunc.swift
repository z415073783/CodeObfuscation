//
//  File.swift
//  
//
//  Created by zlm on 2019/12/29.
//

import Foundation
import MMScriptFramework
class RegularFunc {
    //字符中的常用符号
    static let kRegularChar = "^$*+?!{}[](),.:<|&-"
    
    //删除前缀名字
    class func replacePrefix(name: String, needRemovePrefix: String) -> String {
        return name.regularExpressionReplace(pattern: "^\(needRemovePrefix)", with: "") ?? name
    }
    
    
    /// 检查配置文件中的相同名字并覆盖
    /// - Parameters:
    ///   - container: 主体
    ///   - oldName: 原有名字
    ///   - newName: 新名字
    class func checkAndReplace(container: String, oldName: String, newName: String) -> String {
        var pattern = checkChar(name: oldName)
        //增加前后过滤规则
        pattern = "(?<![a-zA-Z_=\\.])\(pattern)(?![a-zA-Z_=\\.])"
//        MMLOG.info("pattern = \(pattern)")
        return container.regularExpressionReplace(pattern: pattern, with: newName) ?? container
    }
    
    /// 检查文件内容并替换新名字
    /// - Parameters:
    ///   - container: 主体
    ///   - oldName: 原有名字
    ///   - newName: 新名字
    class func replaceNewName(container: String, oldName: String, newName: String) -> String {
        var pattern = checkChar(name: oldName)
        pattern = "(?<![a-zA-Z_=\\-])\(pattern)(?![a-zA-Z_=\\-])"
//        MMLOG.info("pattern = \(pattern)")
        return container.regularExpressionReplace(pattern: pattern, with: newName) ?? container
    }
    
    
    
    //过滤正则符号
    class func checkChar(name: String) -> String {
        var pattern = ""
        //过滤正则常用符号
        for nameChar in name {
            for regChar in kRegularChar {
                if nameChar == regChar {
                    pattern = pattern + String(nameChar == regChar ? "\\" : "")
                    continue
                }
            }
            pattern += String(nameChar)
        }
        return pattern
    }

}
