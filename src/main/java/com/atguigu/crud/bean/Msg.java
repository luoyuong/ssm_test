package com.atguigu.crud.bean;

import java.util.HashMap;
import java.util.Map;

/**
 *
 * 通用的返回
 *
 * @author hy
 * @create 2022-03-20 15:46
 * @Description
 */
public class Msg {

    //状态码100-成功,200-失败
    private int code;

//   提示信息
    private String msg;

    //用户要返回给浏览器的数据
    private Map<String,Object> extend = new HashMap<>();

    public static Msg success(){
        Msg result = new Msg();
        result.setCode(100);
        result.setMsg("处理成功!");
        return result;
    }
    public static Msg fail(){
        Msg result = new Msg();
        result.setCode(200);
        result.setMsg("处理失败!");
        return result;
    }

//    添加信息的方法
    
    public Msg add(String key,Object value){
        this.getExtend().put(key,value);
        return this;
    }


    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public Map<String, Object> getExtend() {
        return extend;
    }

    public void setExtend(Map<String, Object> extend) {
        this.extend = extend;
    }
}
