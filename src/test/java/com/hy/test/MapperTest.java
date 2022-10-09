package com.hy.test;


import com.atguigu.crud.bean.Department;
import com.atguigu.crud.bean.Employee;
import com.atguigu.crud.bean.EmployeeExample;
import com.atguigu.crud.dao.DepartmentMapper;
import com.atguigu.crud.dao.EmployeeMapper;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.List;

/**
 * @author hy
 * @create 2022-03-20 10:16
 * @Description
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {"classpath:applicationContext.xml"})
public class MapperTest {

    @Autowired
    EmployeeMapper employeeMapper;

    @Autowired
    DepartmentMapper departmentMapper;

    @Test
    public void test1(){
        EmployeeExample example = new EmployeeExample();
        example.createCriteria().andEmpIdBetween(0,10);

        Employee employee = employeeMapper.selectByPrimaryKeyWithDepartment(5);

        System.out.println(employee.getDepartment());
    }

    @Test
    public void test2(){
        List<Employee> departments = employeeMapper.selectByExample(null);

        departments.forEach(department -> System.out.println(department));
    }

}
