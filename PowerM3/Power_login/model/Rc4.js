
//判断对象是否为数组
isArray = function (source) {
    return '[object Array]' == Object.prototype.toString.call(source);
};

//获取根路径，例如  http://12.3.4.5/powerpip/
function getRootPath() {
    var strFullPath = window.document.location.href;
    var strPath = window.document.location.pathname;
    var pos = strFullPath.indexOf(strPath);
    var prePath = strFullPath.substring(0, pos);
    var postPath = strPath.substring(0, strPath.substr(1).indexOf('/') + 1);
    return (prePath + postPath);
}
//获取当前日期 2013-01-02
function getdate() {
    var now = new Date();
    y = now.getFullYear();
    m = now.getMonth() + 1;
    d = now.getDate();
    m = m < 10 ? "0" + m : m;
    d = d < 10 ? "0" + d : d;
    return y + "-" + m + "-" + d;
}
// param 为 参数的名称,获取url 参数值，比如 http://12.3.4.5/powerpip/login.html?aa=bb&cc=dd,  aa/cc 为param ,bb/dd 为返回值,win为url打开的窗体(window/parent),默认是window,
function getParameter(param, win) {
    var wind = win && win != "" ? win : window;
    var query = wind.location.search;
    var iLen = param.length;
    var iStart = query.indexOf("&" + param + "=");
    if (iStart == -1) {
        iStart = query.indexOf("?" + param + "=");
        if (iStart == -1) return "";
    }
    iStart += iLen + 1 + 1;
    var iEnd = query.indexOf("&", iStart);
    if (iEnd == -1)
        return query.substring(iStart);
    
    return query.substring(iStart, iEnd);
}
//是否为空的Guid值 (为空则true,有值为false)
function IsNullGuid(value) {
    if (!value) return true;
    if (value == null || value == "") return true;
    if (value == "00000000-0000-0000-0000-000000000000") return true;
    return false;
}
//补了零的标准的guid格式（当然多了个“guid_”前缀,以及使用“_”代替“-”）。
function CreateGUID() {
    function s4() {
        return Math.floor((1 + Math.random()) * 0x10000)
        .toString(16)
        .substring(1);
    }
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
    s4() + '-' + s4() + s4() + s4();
}
//判断一个值是否为空
function IsEmpty(value) {
    if (value == undefined) return true;
    if (value == null) return true;
    if (value == "") return true;
    if (value == "00000000-0000-0000-0000-000000000000") return true;
    return false;
}
//下面这段代码就是为你的功能而扩充的代码
function setCookie(name, value) {
    var Days = 300; //此 cookie 将被保存 30 天
    var exp = new Date();    //new Date("December 31, 9998");
    exp.setTime(exp.getTime() + Days * 24 * 60 * 60 * 1000);
    document.cookie = name + "=" + escape(value) + ";expires=" + exp.toGMTString();
}
function getCookie(name) {
    var arr = document.cookie.match(new RegExp("(^| )" + name + "=([^;]*)(;|$)"));
    if (arr != null) return unescape(arr[2]); return ""
}
function delCookie(name) {
    var exp = new Date();
    exp.setTime(exp.getTime() - 1);
    var cval = getCookie(name);
    if (cval != null)
        document.cookie = name + "=" + cval + ";expires=" + exp.toGMTString();
}

function moveMessage() {
    $('#messageDIV').animate({ top: '0' }, 500, function () {
                             //  $(this).css({ display: 'none', top: '-200px' });
                             $(this).remove();
                             });
}
function ShowMessage(msg) {
    var messageDiv = "<div id='messageDIV' class='MessageCss' style='position: absolute;'></div>";
    $(document.body).append(messageDiv);
    $('#messageDIV')[0].innerHTML = "<font color='red'>" + msg + "</font>";
    
    $('#messageDIV').css({ display: 'block', top: '200px' }).animate({ top: '+50' }, 2000, function () {
                                                                     setTimeout(moveMessage, 1000);
                                                                     });
}
//打开弹出窗体
function OpenWindow(url, openType, iWidth, iHeight) {
    if (!iWidth || parseInt(iWidth) < 1)
        iWidth = this.innerWidth * 0.75;
    if (!iHeight || parseInt(iHeight) < 1)
        iHeight = this.innerHeight * 0.75;
    
    var arg = "dialogWidth=" + iWidth + "px;dialogHeight=" + iHeight + "px;";
    
    switch (openType.toLowerCase()) {
        case "modal":
            if ((!iWidth || parseInt(iWidth) < 1) && (!iHeight || parseInt(iHeight) < 1)) {
                window.showModalDialog(url, ""); //, arg
            }
            else {
                window.showModalDialog(url, "", "dialogWidth=" + iWidth + "px;dialogHeight=" + iHeight + "px");
            }
            break;
        case "div":
            if ((!iWidth || parseInt(iWidth) < 1) && (!iHeight || parseInt(iHeight) < 1)) {
                mini.open({
                          url: url,
                          showMaxButton: true
                          });
            }
            else {
                mini.open({
                          url: url,
                          width: iWidth,
                          height: iHeight,
                          showMaxButton: true
                          });
            }
            break;
        case "tabs":
            window.open(url);
            break;
    }
}
//关闭弹出窗体,参数： 关闭前执行的方法
function ComToolsCloseWindow(action, preclose) {
    if (preclose != undefined) {
        if (!preclose())
            return;
    }
    if (window.CloseOwnerWindow) { //mini.open 的关闭方法
        window.CloseOwnerWindow(action);
    }
    else {
        if (window.parent && window.parent.CloseOwnerWindow) //嵌套流程框的时候
            window.parent.CloseOwnerWindow(action);
        else
            window.close();
    }
}

//获取url中的参数
function request(strParame, url) {
    var args = new Object();
    var query = "";
    if (!url)
        query = unescape(location.search.substring(1)); // Get query string
    else {
        var index = url.indexOf("?");
        query = url.substring(index + 1);
    }
    var pairs = query.split("&"); // Break at ampersand
    for (var i = 0; i < pairs.length; i++) {
        var pos = pairs[i].indexOf('='); // Look for "name=value"
        if (pos == -1) continue; // If not found, skip
        var argname = pairs[i].substring(0, pos); // Extract the name
        var value = pairs[i].substring(pos + 1); // Extract the value
        try {
            value = decodeURIComponent(value); // Decode it, if needed
        }
        catch (e) { }
        args[argname] = value; // Store as a property
    }
    return args[strParame]; // Return the object
}

var Base64 = {
    
    // private property
_keyStr: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
    // public method for encoding
encode: function (input) {
    var output = "";
    var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
    var i = 0;
    
    input = Base64._utf8_encode(input);
    
    while (i < input.length) {
        
        chr1 = input.charCodeAt(i++);
        chr2 = input.charCodeAt(i++);
        chr3 = input.charCodeAt(i++);
        
        enc1 = chr1 >> 2;
        enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
        enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
        enc4 = chr3 & 63;
        
        if (isNaN(chr2)) {
            enc3 = enc4 = 64;
        } else if (isNaN(chr3)) {
            enc4 = 64;
        }
        
        output = output +
        this._keyStr.charAt(enc1) + this._keyStr.charAt(enc2) +
        this._keyStr.charAt(enc3) + this._keyStr.charAt(enc4);
        
    }
    
    return output;
},
    
    // public method for decoding
decode: function (input) {
    var output = "";
    var chr1, chr2, chr3;
    var enc1, enc2, enc3, enc4;
    var i = 0;
    
    input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");
    
    while (i < input.length) {
        
        enc1 = this._keyStr.indexOf(input.charAt(i++));
        enc2 = this._keyStr.indexOf(input.charAt(i++));
        enc3 = this._keyStr.indexOf(input.charAt(i++));
        enc4 = this._keyStr.indexOf(input.charAt(i++));
        
        chr1 = (enc1 << 2) | (enc2 >> 4);
        chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
        chr3 = ((enc3 & 3) << 6) | enc4;
        
        output = output + String.fromCharCode(chr1);
        
        if (enc3 != 64) {
            output = output + String.fromCharCode(chr2);
        }
        if (enc4 != 64) {
            output = output + String.fromCharCode(chr3);
        }
        
    }
    
    output = Base64._utf8_decode(output);
    
    return output;
    
},
    
    // private method for UTF-8 encoding
_utf8_encode: function (string) {
    string = string.replace(/\r\n/g, "\n");
    var utftext = "";
    
    for (var n = 0; n < string.length; n++) {
        
        var c = string.charCodeAt(n);
        
        if (c < 128) {
            utftext += String.fromCharCode(c);
        }
        else if ((c > 127) && (c < 2048)) {
            utftext += String.fromCharCode((c >> 6) | 192);
            utftext += String.fromCharCode((c & 63) | 128);
        }
        else {
            utftext += String.fromCharCode((c >> 12) | 224);
            utftext += String.fromCharCode(((c >> 6) & 63) | 128);
            utftext += String.fromCharCode((c & 63) | 128);
        }
        
    }
    
    return utftext;
},
    
    // private method for UTF-8 decoding
_utf8_decode: function (utftext) {
    var string = "";
    var i = 0;
    var c = c1 = c2 = 0;
    
    while (i < utftext.length) {
        
        c = utftext.charCodeAt(i);
        
        if (c < 128) {
            string += String.fromCharCode(c);
            i++;
        }
        else if ((c > 191) && (c < 224)) {
            c2 = utftext.charCodeAt(i + 1);
            string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
            i += 2;
        }
        else {
            c2 = utftext.charCodeAt(i + 1);
            c3 = utftext.charCodeAt(i + 2);
            string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
            i += 3;
        }
        
    }
    
    return string;
},
    
rc4: function (data) {
    var key = "PowerM3";
    var seq = Array(256);//int
    var das = Array(data.length);//code of data
    for (var i = 0; i < 256; i++)
        seq[i] = i;
    var j = 0;
    for (var i = 0; i < 256; i++) {
        var j = (j + seq[i] + key.charCodeAt(i % key.length)) % 256;
        var temp = seq[i];
        seq[i] = seq[j];
        seq[j] = temp;
    }
    for (var i = 0; i < data.length; i++)
        das[i] = data.charCodeAt(i);
    for (var x = 0; x < das.length; x++) {
        var i = (i + 1) % 256;
        var j = (j + seq[i]) % 256;
        var temp = seq[i];
        seq[i] = seq[j];
        seq[j] = temp;
        var k = (seq[i] + seq[j]) % 256;
        das[x] = String.fromCharCode(das[x] ^ seq[k]);
    }
    return das.join('');
}
}
//客户端Base64编码
function base64encode(str) {
    if (str == undefined || str.length == 0)
        return "";
    return Base64.encode(str);
}
//客户端Base64解码
function base64decode(str) {
    if (str == undefined || str.length == 0)
        return "";
    return Base64.decode(str);
}

function base64swhere(str) {
    if (str == undefined || str.length == 0)
        return "";
    return encodeURIComponent(Base64.rc4(str));
}
//用Post方式向服务器提交数据
function postDataToServer(postUrl, data) {
    //$("#frmpostdata").remove();
    //$("#frmpopwin").remove();
    $("#postdatapanel").remove();
    var posthtml = [];
    posthtml.push("<div id='postdatapanel' style='display:none;'>");
    posthtml.push("<iframe name='frmpopwin' id='frmpopwin' style='display:none;width:0px;height:0px;'></iframe>");
    posthtml.push("<form id='frmpostdata' method='post' target='frmpopwin' action='" + postUrl + "'>");
    for (var k in data) {
        if (typeof (data[k]) != "function")
            posthtml.push("<textarea name='" + k + "'>" + data[k] + "</textarea>");
    }
    posthtml.push("</form>");
    posthtml.push("</div>");
    $("body").append(posthtml.join(""));
    $("#frmpostdata")[0].submit();
}

//替换所有页面的标签，大小写统一,按照标签与格式相匹配直接替换
var replaceTempate = function (obj, jsonDatas) {
    var obj = $("#" + obj);
    //通用替换模版
    var template = obj.html();
    var content = "";
    for (var i = 0; i <= jsonDatas.length - 1; i++) {
        var a = template;
        
        for (var m in jsonDatas[i]) {
            var reg = new RegExp("\\$" + m + "\\$", "gim");
            var v = eval("jsonDatas[i]." + m);
            a = a.replace(reg, v);
        }
        content += a.replace("$loop$", (i + 1));
    }
    
    obj.html(content);
}

//将二维结构转为树成结构
function convert(source) {
    var tmp = {}, parent, parentList = [], n;
    for (n in source) {
        var item = source[n];
        if (item.ParentID == -1) {
            parentList.push(item.ID);
        }
        if (!tmp[item.ID]) {
            tmp[item.ID] = {};
        }
        tmp[item.ID].Name = item.Name;
        //tmp[item.ID].ID = item.ID;
        if (!("children" in tmp[item.ID])) tmp[item.ID].children = [];
        
        if (item.ID != item.ParentID) {
            if (tmp[item.ParentID]) {
                tmp[item.ParentID].children.push(tmp[item.ID]);
            }
            else {
                tmp[item.ParentID] = { children: [tmp[item.ID]] };
            }
        }
    }
    
    var result = [];
    for (var i = 0; i < parentList.length; i++) {
        result.push(tmp[parentList[i]]);
    }
    return result;
}
//获取当前可视区域高度
function getInnerHeight(t) {
    var win = (t == "top") ? top.window : window;
    return (win.innerHeight || (win.document.documentElement.clientHeight || win.document.body.clientHeight));
}
//获取当前可视区域长度
function getInnerWidth(t) {
    var win = (t == "top") ? top.window : window;
    var de = win.document.documentElement;
    return win.innerWidth || self.innerWidth || (de && de.clientWidth) || win.document.body.clientWidth;
}


//Ajax 访问数据集和业务对象，返回json
var getDataJson = function (jsonData, CallBackFun) {
    //jsonData  数组
    //CallBackFun 回调函数名 将json对象返回
    $.ajax({
           type: 'POST',
           url: '/Data/GetDataJson',
           data: { json: mini.encode(jsonData) },
           dataType: 'json',
           async: false,
           success: function (result) {
           var tmpData = mini.decode(result);
           if (tmpData.success == false) {
           alert(tmpData.message); return;
           }
           if (CallBackFun) CallBackFun(tmpData);
           },
           error: function (result, status) {
           alert(status);
           return;
           }
           })
};

var fomateDate = function(oDate,sFomate, bZone) {
    
    sFomate = sFomate.replace("YYYY", oDate.getFullYear());
    sFomate = sFomate.replace("YY", String(oDate.getFullYear()).substr(2))
    sFomate = sFomate.replace("MM", oDate.getMonth() + 1)
    sFomate = sFomate.replace("DD", oDate.getDate());
    sFomate = sFomate.replace("hh", oDate.getHours());
    sFomate = sFomate.replace("mm", oDate.getMinutes());
    sFomate = sFomate.replace("ss", oDate.getSeconds());
    if (bZone) sFomate = sFomate.replace(/\b(\d)\b/g, '0$1');
    return sFomate;
}
//string.Format()  http://www.cnblogs.com/loogn/archive/2011/06/20/2085165.html
String.prototype.format = function (args) {
    var result = this;
    if (arguments.length > 0) {
        if (arguments.length == 1 && typeof (args) == "object") {
            for (var key in args) {
                if (args[key] != undefined) {
                    var reg = new RegExp("({" + key + "})", "g");
                    result = result.replace(reg, args[key]);
                }
            }
        }
        else {
            for (var i = 0; i < arguments.length; i++) {
                if (arguments[i] != undefined) {
                    //var reg = new RegExp("({[" + i + "]})", "g");//这个在索引大于9时会有问题，谢谢何以笙箫的指出
                    
                    var reg = new RegExp("({)" + i + "(})", "g");
                    result = result.replace(reg, arguments[i]);
                }
            }
        }
    }
    return result;
}
