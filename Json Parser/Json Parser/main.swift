//
//  main.swift
//  Json Parser
//
//  Created by 天放 on 2020/10/25.
//
//  to use this jsonParser
//  just call the function jsonParser(input:String)
//  and it will return the beautify json result

import Foundation

var currentLevel:Int = 0
var output:String = ""

private func format()
{
    if(currentLevel<1)
    {
        return
    }
    for _ in 1...currentLevel
    {
        output.append("\t")
    }
}

private func nullParser(input:String)->(isSuccess:Bool,remString:String)
{
    if(String(input.trimmingCharacters(in: .whitespacesAndNewlines)).hasPrefix("null"))
    {
        output.append("null")
        return (true,String(String(input.trimmingCharacters(in: .whitespaces)).dropFirst(4)))
    }
    return(false," ")
}

private func boolParser(input:String)->(isSuccess:Bool,remString:String)
{
    if(String(input.trimmingCharacters(in: .whitespacesAndNewlines)).hasPrefix("true"))
    {
        output.append("true")
        return(true,String(String(input.trimmingCharacters(in: .whitespaces)).dropFirst(4)))
    }
    else if(String(input.trimmingCharacters(in: .whitespacesAndNewlines)).hasPrefix("false"))
    {
        output.append("false")
        return(true,String(String(input.trimmingCharacters(in: .whitespaces)).dropFirst(5)))
    }
    return (false," ")
}

private func stringParser(input:String)->(isSuccess:Bool,remString:String)
{
    var inputArray=Array(input.trimmingCharacters(in: .whitespacesAndNewlines))
    var strArray=[String]()
    //var foundClosingQuotes = false
    
    if(inputArray[0] == "\"")
    {
        inputArray.remove(at: 0)
        output.append("\"")
        var totalCount = inputArray.count
        
        while(totalCount>0)
        {
            let val = inputArray[0]
            switch val
            {
            case "\\":
                if["\"","\\","/","b","f","n","r","t"].contains(String(inputArray[1]))
                {
                    strArray.append(String(inputArray.remove(at: 0)))
                    strArray.append(String(inputArray.remove(at: 0)))
                    totalCount -= 2
                }
                else if(String(inputArray[1])=="u")
                {
                    if(inputArray.indices.contains(5))
                    {
                        strArray.append(String(inputArray.remove(at: 0)))
                        strArray.append(String(inputArray.remove(at: 0)))
                        totalCount -= 2
                        
                        for _ in 0...3
                        {
                            if["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","a", "b","c", "d","e","f"].contains(String(inputArray[0]))
                            {
                                strArray.append(String(inputArray.remove(at: 0)))
                                totalCount -= 1
                            }
                            else
                            {
                                return(false," ")
                            }
                        }
                    }
                    else
                    {
                        return (false," ")
                    }
                }
            case "\"":
                strArray.append("\"")
                output.append(strArray.joined())
                inputArray.remove(at: 0)
                return(true,String(inputArray))
            default:
                strArray.append(String(inputArray.remove(at: 0)))
                totalCount -= 1
            }
        }
    }
    return (false," ")
}

private func numberParser(input:String)->(isSuccess:Bool,remString:String)
{
    var inputArray = Array(input.trimmingCharacters(in: .whitespacesAndNewlines))
    var intCount = 0
    var intArray = [String]()
    var isDecimalDone = false
    var isExponentDone = false
    var isMinusDone = false
    var isPlusDone = false
    var totalCount = inputArray.count
    var index = 0
    
    if( ["0","1","2","3","4","5","6","7","8","9"].contains(inputArray[0]) || inputArray[0]=="-" )
    {
        while(totalCount>0)
        {
            let val = inputArray[0]
            switch val
            {
            case "-":
                if(isMinusDone == false)
                {
                    if let _:Int = Int(String(inputArray[1]))
                    {
                        if(index == 0 || isExponentDone)
                        {
                            intArray.append("-")
                            inputArray.remove(at: 0)
                            totalCount = totalCount - 1
                            index = index + 1

                            if(isExponentDone) {
                                isMinusDone = true
                            }
                        }
                        else
                        {
                            return (false," ")
                        }
                    }
                    else
                    {
                        return (false," ")
                    }
                }
                else
                {
                    return (false," ")
                }
            case "+":
                if(isPlusDone==false && isExponentDone) {
                    if let _:Int = Int(String(inputArray[1])) {
                        intArray.append("+")
                        inputArray.remove(at: 0)
                        totalCount = totalCount - 1
                        isPlusDone = true
                    }
                    else {
                        return (false," ")
                    }
                }
                else {
                    return (false," ")
                }
            case "1","2","3","4","5","6","7","8","9":
                intCount += 1
                intArray.append(String(val))
                inputArray.remove(at: 0)
                totalCount = totalCount - 1
            case "0":
                if( (intCount > 0) || (inputArray.count == 1) || !(["0","1","2","3","4","5","6","7","8","9"].contains(inputArray[1])) ) {
                                    intCount += 1
                    intArray.append(String(val))
                    inputArray.remove(at: 0)
                    totalCount = totalCount - 1
                }
                else {
                    return (false," ")
                }
            case ".":
                if(isDecimalDone == false && intCount > 0) {
                    if let _:Int = Int(String(inputArray[1])) {
                        intArray.append(".")
                        inputArray.remove(at: 0)
                        totalCount = totalCount - 1
                        isDecimalDone = true
                    }
                    else {
                        return (false," ")
                    }
                }
                else {
                    return (false," ")
                }
            case "e", "E":
                if(isExponentDone==false) {
                    intArray.append(String(val))
                    inputArray.remove(at: 0)
                    totalCount = totalCount - 1
                    isExponentDone = true
                }
            default:
                output.append("\(intArray.joined())")
                return (true, String(inputArray))
            }
        }
    }
    else
    {
        return (false," ")
    }
    output.append("\(intArray.joined())")
    return (true, String(inputArray))
}

private func arrayParser(input:String)->(isSuccess:Bool,remString:String)
{
    var inputString = input.trimmingCharacters(in: .whitespacesAndNewlines)
    if(inputString.hasPrefix("[")) {
        output.append("[\n")
        currentLevel += 1
        format()
        inputString.remove(at: inputString.startIndex)
        inputString.trimmingCharacters(in: .whitespacesAndNewlines)
        var foundType = false
        while(inputString.count > 0) {
            if(inputString.hasPrefix("]")) {
                output.append("\n")
                currentLevel -= 1
                format()
                output.append("]")
                inputString = String(inputString.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
                return (true, inputString)
            }
            for function in arrFunc {
                let result = function(inputString)
                if(result.isSuccess)
                {
                    inputString = result.remString
                    foundType = true
                    break
                }
            }
            if(foundType == false) {
                return (false, " ")
            }

            foundType = false
            inputString = inputString.trimmingCharacters(in: .whitespacesAndNewlines)

            if(inputString[inputString.startIndex] == "]") {
                output.append("\n")
                currentLevel -= 1
                format()
                output.append("]")
                if(inputString.count > 0){
                    inputString = String(inputString.dropFirst())
                }
                return (true, inputString)
            }

            if(inputString[inputString.startIndex] == ",") {
                output.append(",\n")
                format()
                if(inputString.count > 0) {
                    inputString = String(inputString.dropFirst())
                }
                if(inputString.count > 0) {
                    if(inputString[inputString.startIndex] == "]") {
                        return (false, " ")
                    }
                }
            }
            inputString = inputString.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return (false, " ")
    }
    return (false, " ")
}

private func objectParser(input:String)->(isSuccess:Bool,remString:String)
{
    var inputString  = input.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if(inputString[inputString.startIndex] == "{") {
        output.append("{\n")
        currentLevel += 1
        format()
        var foundType = false
        inputString = String(inputString.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
        if(inputString[inputString.startIndex] == "}") {
            output.append("\n}")
            inputString = String(inputString.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
            return (true, inputString)
        }

        while(inputString.count > 0) {
            inputString = inputString.trimmingCharacters(in: .whitespacesAndNewlines)
            let result = stringParser(input: inputString)
            if(result.isSuccess == false) {
                return (false, " ")
            }
            else {
                inputString = result.remString.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if(inputString[inputString.startIndex] != ":") {
                    return (false, " ")
                }
                output.append(":")
                inputString = String(inputString.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
                for function in arrFunc {
                    let result = function(inputString)
                    if (result.isSuccess) {
                        inputString = (result.remString).trimmingCharacters(in: .whitespacesAndNewlines)
                        foundType = true
                        break
                    }
                }

                if(foundType == false) {
                    return (false, " ")
                }
                foundType = false
                if let indexOfSeparation = inputString.firstIndex(where: { ($0 == ",") || ($0 == "}") }) {
                    let charSeparation = inputString[indexOfSeparation]
                    if charSeparation == "}" {
                        output.append("\n")
                        currentLevel -= 1
                        format()
                        output.append("}")
                        inputString = String(inputString.dropFirst())
                        return (true, inputString)
                    }
                    if charSeparation == "," {
                        output.append(",\n")
                        format()
                        inputString = String(inputString.dropFirst())
                    }
                }
                else {
                    return (false, " ")
                }
            }
        }
    }
    return (false, " ")
}

let arrFunc=[nullParser, boolParser, stringParser, numberParser, arrayParser,objectParser]

public func jsonParser(input:String)->String
{
    var inputString = input
    inputString = inputString.trimmingCharacters(in: .whitespacesAndNewlines)
    
    for function in arrFunc
    {
        let result = function(inputString)
        if(result.isSuccess)
        {
            return output
        }
    }
    return "false"
}

var json2:String = "{\"站长\":\"SOJSON，QQ:so@sojson.com\",\"域名\":\"https://www.sojson.com\",\"开发语言\":\"最牛逼的语言——Java ^_^\",\"编码\":\"UTF-8\",\"技术使用\":[\"SpringMVC\",\"Mybatis \",\"Freemarker\",\"Shiro\"],\"数据存储\":[\"Redis\",\"RDS\",\"Upyun云存储\"],\"服务器\":[{\"阿里云ECS x 3\":{\"配置\":[{\"CPU\":\"4核\",\"内存\":\"16GB\",\"一年费用\":\"¥14000.00\"}]}}]}"

var json1:String="      {  \"1\":null,\"2\":456,\"sss\":true,\"gogogo\":[1,2,3,[4,5,6]]}     "

var json3:String = "{\"title\":\"json在线解析（简版） -JSON在线解析\",\"json.url\":\"https://www.sojson.com/simple_json.html\",\"keywords\":\"json在线解析\",\"功能\":[\"JSON美化\",\"JSON数据类型显示\",\"JSON数组显示角标\",\"高亮显示\",\"错误提示\",{\"备注\":[\"www.sojson.com\",\"json.la\"]}],\"加入我们\":{\"qq群\":\"259217951\"}}"

print(jsonParser(input: json2))

