package com.atguigu.crud.controller;

import com.atguigu.crud.bean.Employee;
import com.atguigu.crud.bean.Msg;
import com.atguigu.crud.service.EmployeeService;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author hy
 * @create 2022-03-20 10:54
 * @Description
 */
@Controller
public class EmployeeController {

    @Autowired
    EmployeeService employeeService;


    /**
     * 单个批量二合一
     * 批量删除1-2-3
     * 单个删除1
     * @param ids
     * @return
     */
    @RequestMapping(value = "/emp/{ids}",method = RequestMethod.DELETE)
    @ResponseBody
    public Msg deleteEmpById(@PathVariable("ids") String ids){
        if(ids.contains("-")){
            //批量删除
            List<Integer> del_ids = new ArrayList<>();
            String[] str_ids = ids.split("-");
            for(String str:str_ids){
                del_ids.add(Integer.parseInt(str));
            }
            employeeService.deleteBatch(del_ids);
        }else {
            //单个删除
            employeeService.deleteById(Integer.parseInt(ids));
        }
        return Msg.success();
    }


    /**
     *
     * 如果直接发送ajax=PUT形式的请求
     * 封装的数据
     *更新的数据:Employee{empId=5, department=null, empName='null', gender='null', email='null'}
     *
     * 问题：
     * 请求体中有数据
     * 但是Employee对象获取不到
     *
     * 原因:
     *  1.Tomcat将请求头中的数据,封装成一个map
     *  2.request.getParameter("empName")就可以进行取值
     *  3.SpringMVC封装Bean对象的时候是
     *      会把Bean对象每个属性的值,request.getParameter("email");
     *
     *  但只有是Post请求的时候才能获取到值
     *
     *
     *  解决方案
     *  我们要能支持直接发送PUT之类的请求还要封装请求头中的数据
     *  配置上HttpFutForemContentFilter
     *  作用:将请求头中的数据解析包装成一个map
     *  request被重新包装,request.getParaeter()被重写,就会从自己封装的map中去数据
     *
     * 员工更新方法
     * @param employee
     * @return
     */
    @RequestMapping(value = "/emp/{empId}",method = RequestMethod.PUT)
    @ResponseBody
    public Msg saveEmp(Employee employee){
        System.out.println("更新的数据:"+employee);

        employeeService.updateEmp(employee);

        return Msg.success();
    }


    /**
     * 根据id查询员工
     * @param id
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "/emp/{id}",method = RequestMethod.GET)
    public Msg getEmp(@PathVariable("id") Integer id){

        Employee employee = employeeService.getEmp(id);
        return Msg.success().add("emp",employee);
    }

    /**
     * 检查用户名是否可用
     * @param empName
     * @return
     */
    @RequestMapping("/checkuser")
    @ResponseBody
    public Msg checkuse(@RequestParam("empName") String empName){
        //先判断用户名是否合法的表达式
        String regx = "(^[a-zA-Z0-9_-]{5,16}$)|(^[\\u2E80-\\u9FFF]{2,5}$)";
        if(!empName.matches(regx)){
            return Msg.fail().add("va_msg","用户名不合法");
        }

        boolean b = employeeService.checkUser(empName);
        if (b){
            return Msg.success();
        }else {
            return Msg.fail().add("va_msg","用户名重复");
        }
    }

    /**
     * 员工保存
     *
     * 1.支持JSR303校验
     * 2.导入Hibernate-Validator
     *
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "/emp",method = RequestMethod.POST)
    //@Valid:代表封装的对象要进行校验
    public Msg saveEmp(@Valid Employee employee, BindingResult result){
        //result.hasErrors():如果校验有错误
        if(result.hasErrors()){
            //校验失败,应该返回失败,在模态框中显示校验失败的信息
            Map<String,Object> map = new HashMap<>();
            List<FieldError> errors = result.getFieldErrors();
            for(FieldError error:errors){
                System.out.println("错误的字段名"+error.getField());
                System.out.println("错误信息:"+error.getDefaultMessage());
                map.put(error.getField(),error.getDefaultMessage());
            }
            return Msg.fail().add("errorFields",map);
        }else {
            employeeService.saveEmp(employee);
            return Msg.success();
        }
    }

    /**
     * 导入jackson包,@ResponseBody才能正常工作
     * 返回json类型的数据
     * @param pn
     * @param model
     * @return
     */
    @RequestMapping("/emps")
    @ResponseBody
    public Msg getEmpsWithJson(@RequestParam(value = "pn" ,defaultValue = "1") Integer pn,
                               Model model){
        PageHelper.startPage(pn,5);

        List<Employee> employees = employeeService.getAll();

        PageInfo pageInfo = new PageInfo(employees,5);

        return Msg.success().add("pageInfo",pageInfo);
    }

//    @RequestMapping(value = "/emps",method = RequestMethod.GET)
    public String getEmps(
            @RequestParam(value = "pn", defaultValue = "1") Integer pn,
            HttpServletRequest request) {
        // 这不是一个分页查询；
        // 引入PageHelper分页插件
        // 在查询之前只需要调用，传入页码，以及每页的大小
        PageHelper.startPage(pn, 5);
        // startPage后面紧跟的这个查询就是一个分页查询
        // 使用pageInfo包装查询后的结果，只需要将pageInfo交给页面就行了。
        // 封装了详细的分页信息,包括有我们查询出来的数据，传入连续显示的页数
        List<Employee> employees = employeeService.getAll();
        PageInfo page = new PageInfo(employees, 5);

        request.setAttribute("pageInfo",page);

        return "list";
    }

}
