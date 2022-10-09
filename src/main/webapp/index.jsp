<%--
  Created by IntelliJ IDEA.
  User: hy
  Date: 2022/3/20
  Time: 14:08
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
    <title>员工列表</title>
    <%--  web路径
        不以/开始的相对路径,找资源,以当前的路径为基准,经常容易出问题
        以/开始的相对路径,找资源,以服务器为标签(http://localhost:3306)需要自己加上项目名
                http://localhost:3306/ssm_demo
      --%>
    <%
        pageContext.setAttribute("APP_PATH",request.getContextPath());
    %>

    <!-- Bootstrap -->

    <script type="text/javascript" src="${APP_PATH}/static/js/jquery-1.12.4.min.js"></script>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">

    <script src="https://stackpath.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>


    <script type="text/javascript">
        //1.页面加载完成以后,直接发送员工ajax请求,要到分页数据
        var totalRecord;
        //当前页码
        var currentPage;
        $(function () {
            //去首页
            to_Page(1)

            //按钮绑定模块框
            $("#emp_add_modal_btn").click(function () {
                //清除表单数据
                //dom对象的方法:所以要用[]取出来(表单要完整重置)
                reset_form("#empAddModal form");

                //发送ajax请求,查出部门信息
                getDepts("#dept_add_select");

                //弹出模态框
                $("#empAddModal").modal(function () {
                    backdrop:"static"
                })
            });

            //校验
            $("#empName_add_input").change(function () {
                //发送ajax请求校验用户名是否可用
                var empName = this.value;
                $.ajax({
                    url:"${APP_PATH}/checkuser",
                    data:"empName="+empName,
                    method: "POST",
                    success:function (result) {
                        if(result.code == 100){
                            //成功
                            show_validate_msg("#empName_add_input","success","用户名可用");
                            $("#emp_save_btn").attr("ajax-va","success");
                        }else{
                            //失败
                            show_validate_msg("#empName_add_input","error",result.extend.va_msg)
                            $("#emp_save_btn").attr("ajax-va","error");
                        }
                    }
                })
            })

            //点击进行保存
            $("#emp_save_btn").click(function () {
                // reset_form("#empAddModal form");
                // $("#empAddModal form")[0].reset();

                //1.模态框中填写的表单数据交给服务器进行保存
                //1.1先对要提交给服务器的数据进行校验
                if(!validate_add_form()){
                    return false;
                }

                //1.2判断之前的用户名校验是否成功了.如果成功了才继续走
                if($(this).attr("ajax-va") == "error"){
                    return false;
                }

                //2.发送ajax请求保存员工
                $.ajax({
                    url:"${APP_PATH}/emp",
                    method:"POST",
                    data: $(".form-horizontal").serialize(),
                    success:function (result) {
                        if(result.code == 100){
                            // alert("success"+result.msg);
                            //员工保存成功
                            //1.关闭模态框
                            $("#empAddModal").modal("hide");
                            //2.来到最后一页,显示刚才保存的数据
                            //发送ajax请求显示最后一页数据即可

                            to_Page(totalRecord);
                        }else {
                            //显示失败信息
                            console.log(result);
                            //有哪个字段的错误信息就显示哪个字段的：
                            if(undefined != result.extend.errorFields.email){
                                //显示邮箱错误信息
                                show_validate_msg("#email_add_input","error",result.extend.errorFields.email)
                            }
                            if(undefined != result.extend.errorFields.empName){
                                show_validate_msg("#empName_add_input","error",result.extend.errorFields.empName)
                            }

                        }
                    }
                    // error:function (result) {
                    //     //员工保存成功
                    //     //1.关闭模态框
                    //     $("#empAddModal").modal("hide");
                    //     //2.来到最后一页,显示刚才保存的数据
                    //     //发送ajax请求显示最后一页数据即可
                    //
                    //     to_Page(totalRecord);
                    // }

                })

            });

            //check_all
            //完成全选/全不选功能
            $("#check_all").click(function () {
                //attr用来获取checked是undefinded
                //attr获取自定义属性的值
                //prop获取原生值
                //让其他按钮的选择情况与check_all同步
                $(".check_item").prop("checked",$(this).prop("checked"))
            });

            //check_item
            $(document).on("click",".check_item",function () {

                //判断当前选中的元素是否有五个
                var falg = $(".check_item:checked").length == $(".check_item").length;
                $("#check_all").prop("checked",falg);
            })

            //全部删除
            $("#emp_delete_all_btn").click(function () {
                var empNames = "";
                var del_idstr = "";
                $.each($(".check_item:checked"),function () {
                    empNames += $(this).parents("tr").find("td:eq(2)").text();
                    empNames = empNames+",";
                    //组装员工id字符串
                    del_idstr += $(this).parents("tr").find("td:eq(1)").text()+"-";
                });

                empNames = empNames.substring(0,empNames.length-1);
                del_idstr = del_idstr.substring(0,del_idstr.length-1);
                // alert(empNames)
                if(confirm("确认删除["+empNames+"]吗")){
                    //发送ajax请求
                    $.ajax({
                        url:"${APP_PATH}/emp/"+del_idstr,
                        type:"delete",
                        success:function () {
                            alert("删除成功");
                            to_Page(currentPage);
                        }
                    })

                }
            });

            //修改
            $("#emp_update_btn").click(function () {
                //验证邮箱
                //校验邮箱
                var email = $("#email_update_input").val();
                var regEmail = /^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/;
                if(!regEmail.test(email)){
                    // alert("邮箱格式不正确");
                    show_validate_msg("#email_update_input","error","邮箱格式不正确")
                    return false;
                }else {
                    show_validate_msg("#email_update_input","success","")
                }

                //2.发送ajax请求保存更新的员工数据
                $.ajax({
                    url:"${APP_PATH}/emp/"+$(this).attr("edit_id"),
                    type:"PUT",
                    data:$("#empUpdateModal form").serialize(),
                    success:function (result) {
                        // alert(result.msg)
                        //1.关闭对话框
                        $("#empUpdateModal").modal("hide");
                        //回到本页面
                        to_Page(currentPage);
                    }
                })

            });


            });

        //给删除按钮绑定单击事件
        $(document).on("click",".delete_btn",function () {
            //1.弹出确认是否删除对话框
            // alert($(this).parents("tr").find("td:eq(1)").text())
            var empName = $(this).parents("tr").find("td:eq(2)").text();
            if(confirm("确认删除【"+empName+"】吗?")){
                //确认后,发送ajax请求删除即可
                $.ajax({
                    url:"${APP_PATH}/emp/"+$(this).attr("delete_id"),
                    type:"DELETE",
                    success:function (result) {
                        // alert(result.msg);
                        to_Page(currentPage);
                    }
                })
            }
        })

        // 给编辑按钮绑定单击事件
        //1.在按钮创建时绑定单击事件
        //2.使用live方法:JQuery新版没有live方法,就使用on
        $(document).on("click",".edit_btn",function () {
            // alert("edit")
            //1.查出部门信息,并显示部门列表
            getDepts("#dept_update_select")

            //2.查出员工信息,显示员工信息
            getEmp($(this).attr("edit_id"));

            //3.把员工的id传递给模态框的更新按钮
            $("#emp_update_btn").attr("edit_id",$(this).attr("edit_id"));

            //3.弹出模态框
            $("#empUpdateModal").modal({
                backdrop:"static"
            });
        });


        function getEmp(id) {
            $.ajax({
                url:"${APP_PATH}/emp/"+id,
                type:"GET",
                success:function (result) {
                    // console.log(result);
                    var empEle = result.extend.emp;

                    $("#empName_update_static").text(empEle.empName);
                    $("#email_update_input").val(empEle.email);
                    $("#empUpdateModal input[name='gender']").val([empEle.gender]);
                    $("#empUpdateModal select").val([empEle.dId]);
                }
            })
        }

        //重置
        function reset_form(ele) {
            $(ele)[0].reset();
            //清空表单样式
            $(ele).find("*").removeClass("has-error has-success");
            $(ele).find(".help-block").text("");
        }


        //校验表单数据
        function validate_add_form(){
            //1.拿到要校验的数据,使用正则表达式
            //校验用户名
            var empName = $("#empName_add_input").val();
            var regName = /(^[a-zA-Z0-9_-]{5,16}$)|(^[\u2E80-\u9FFF]{2,5}$)/;
            if(!regName.test(empName)){
                //校验失败
                // alert("用户名有问题");
                show_validate_msg("#empName_add_input","error","用户名有问题")
                return false;
            }else {
                //清空之前的样式
                show_validate_msg("#empName_add_input","success","")
            }

            //校验邮箱
            var email = $("#email_add_input").val();
            var regEmail = /^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/;
            if(!regEmail.test(email)){
                // alert("邮箱格式不正确");
                show_validate_msg("#email_add_input","error","邮箱格式不正确")
                // $("#email_add_input").parent().addClass("has-error");
                // $("#email_add_input").next("span").text("邮箱格式不正确");
                return false;
            }else {
                show_validate_msg("#email_add_input","success","")
                // $("#email_add_input").parent().addClass("has-success");
                // $("#email_add_input").next("span").text("");
                return true;
            }

        }

        function show_validate_msg(ele,status,msg){
            $(ele).parent().removeClass("has-success has-error")
            $(ele).next("span").text("");
            if("success" == status){
                $(ele).parent().addClass("has-success");
                $(ele).next("span").text(msg);
            }else if("error" == status){
                $(ele).parent().addClass("has-error");
                $(ele).next("span").text(msg);
            }
        }


        //查出所有的部门信息,并显示在下拉列表
        function getDepts(ele) {
            $.ajax({
                url:"${APP_PATH}/depts",
                type:"GET",
                success:function (result) {
                    $(ele).empty();
                    //result中就是部门的数据
                    // console.log(result);
                    // 显示部门信息在下拉列表中
                    // $("#dept_add_select");
                    $.each(result.extend.depts,function () {
                        //this就代表遍历到的当前对象
                        var optionEle = $("<option></option>").append(this.deptName).attr("value",this.deptId);
                        optionEle.appendTo(ele);
                    });
                }
            });
        }

        //跳转到第几页
        function to_Page(pn) {
            $.ajax({
                url:"${APP_PATH}/emps",
                data:"pn="+pn,
                type:"GET",
                success:function (result) {
                    //result就是那边传过来的msg
                    // console.log(result);
                    //1.解析并显示员工数据
                    build_emps_table(result);

                    //2.解析显示分页信息
                    build_page_info(result);

                    //3.解析显示分页条
                    build_page_nav(result);
                }
            })
        }

        //解析员工列表的
        function build_emps_table(result) {
            //清空之前的数据
            $("#emps_table tbody").empty();

            var emps = result.extend.pageInfo.list;
            $.each(emps,function (index,item) {
                var checkBoxTd = $("<td><input type='checkbox' class='check_item'/></td>")

                var empIdTd = $("<td></td>").append(item.empId);
                var empNameTd = $("<td></td>").append(item.empName);
                var gender = item.gender=='M'?"男":"女";
                var genderTd = $("<td></td>").append(gender);
                var emailTd = $("<td></td>").append(item.email);
                var deptNameTd = $("<td></td>").append(item.department.deptName);
                /**
                 * <button class="btn btn-primary btn-sm">
                     <span class="glyphicon glyphicon-pencil " aria-hidden="true"></span>
                    编辑
                    </button>
                 */
                var editBtn = $("<button></button>").addClass("btn btn-primary btn-sm edit_btn")
                              .append($("<span></span>").addClass("glyphicon glyphicon-pencil"))
                              .append("编辑")
                //为编辑按钮添加一个自定义的属性,来标识当前员工id
                editBtn.attr("edit_id",item.empId)

                var delBtn = $("<button></button>").addClass("btn btn-danger btn-sm delete_btn")
                              .append($("<span></span>").addClass("glyphicon glyphicon-trash"))
                              .append("删除")
                //为删除按钮添加一个自定义的属性,来标识当前员工id
                delBtn.attr("delete_id",item.empId);

                var btnTd = $("<td></td>").append(editBtn).append(" ").append(delBtn);
                //append方法执行完成后还是返回原来的元素
                $("<tr></tr>").append(checkBoxTd).append(empIdTd)
                .append(empNameTd).append(genderTd)
                .append(emailTd).append(deptNameTd)
                .append(btnTd)
                .appendTo("#emps_table tbody");
            });
        }

        //解析分页信息的
        function build_page_info(result) {
            //清空之前的数据
            $("#page_info_area").empty();

            //当前 页,总 页,总 条记录数
            var pageInfo = result.extend.pageInfo;
            $("#page_info_area").append("当前"+pageInfo.pageNum+"页,总"+pageInfo.pages+"页,总"+pageInfo.total+"条记录数")
            currentPage = pageInfo.pageNum;
            totalRecord = pageInfo.total;
        }

        //解析分页条的
        function build_page_nav(result) {
            //清空之前的数据
            $("#page_nav_area").empty();

            var ul = $("<ul></ul>").addClass("pagination");
            var pageInfo = result.extend.pageInfo;

            var firstPageLi = $("<li></li>")
                              .append($("<a></a>").append("首页").attr("href","#"))
            var lastPageLi = $("<li></li>")
                              .append($("<a></a>").append("末页").attr("href","#"))

            var prePageLi = $("<li></li>")
                            .append($("<a></a>").append("&laquo;"))


            var nextPageLi = $("<li></li>")
                            .append($("<a></a>").append("&raquo;"))

            if(pageInfo.hasPreviousPage == false){
                firstPageLi.addClass("disabled");
                prePageLi.addClass("disabled");
            }else {
                //为元素添加单击事件
                firstPageLi.click(function () {
                    to_Page(1);
                });

                prePageLi.click(function () {
                    to_Page(pageInfo.pageNum-1);
                });
            }

            if(pageInfo.hasNextPage == false){
                lastPageLi.addClass("disabled");
                nextPageLi.addClass("disabled");
            }else {
                //为元素添加单击事件
                lastPageLi.click(function () {
                    to_Page(pageInfo.pages);
                });

                nextPageLi.click(function () {
                    to_Page(pageInfo.pageNum+1);
                });
            }

            //添加首页和前一页
            ul.append(firstPageLi).append(prePageLi);


            $.each(pageInfo.navigatepageNums,function (index,item) {
                var numLi = $("<li></li>")
                    .append($("<a></a>").append(item));

                //添加显示标识
                if(pageInfo.pageNum == item){
                    numLi.addClass("active");
                }

                //添加单击事件:跳转页面
                numLi.click(function () {
                    to_Page(item)
                })

                //把每一页添加进去
                ul.append(numLi);
            });
            //添加下一页和最后一页
            ul.append(nextPageLi).append(lastPageLi);

            var navEle = $("<nav></nav>").append(ul);

            $("#page_nav_area").append(navEle);
        }

    </script>


</head>
<body>

<!-- 员工修改的模态框 -->
<div class="modal fade" id="empUpdateModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title">员工修改</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal">
                    <div class="form-group">
                        <label class="col-sm-2 control-label">empName</label>
                        <div class="col-sm-10">
                            <p class="form-control-static" id="empName_update_static"></p>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">email</label>
                        <div class="col-sm-10">
                            <input type="text" name="email" class="form-control" id="email_update_input">
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">gender</label>
                        <div class="col-sm-10">
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender1_update_input" value="M" checked="checked"> 男
                            </label>
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender2_update_input" value="F"> 女
                            </label>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">department</label>
                        <div class="col-sm-4">
                            <!--部门提交部门id即可-->
                            <select class="form-control" name="dId" id="dept_update_select">

                            </select>
                        </div>
                    </div>

                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="emp_update_btn">修改</button>
            </div>
        </div>
    </div>
</div>

<!-- 员工添加的模态框 -->
<div class="modal fade" id="empAddModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="myModalLabel">员工添加</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal">
                    <div class="form-group">
                        <label class="col-sm-2 control-label">empName</label>
                        <div class="col-sm-10">
                            <input type="text" name="empName" class="form-control" id="empName_add_input" placeholder="empName">
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">email</label>
                        <div class="col-sm-10">
                            <input type="text" name="email" class="form-control" id="email_add_input" placeholder="email@qq.com">
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">gender</label>
                        <div class="col-sm-10">
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender1_add_input" value="M" checked="checked"> 男
                            </label>
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender2_add_input" value="F"> 女
                            </label>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">department</label>
                        <div class="col-sm-4">
                            <!--部门提交部门id即可-->
                            <select class="form-control" name="dId" id="dept_add_select">

                            </select>
                        </div>
                    </div>

                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="emp_save_btn">保存</button>
            </div>
        </div>
    </div>
</div>

<%--搭建显示页面--%>
<div class="container">
    <div class="row">
        <%--            标题行--%>
        <div class="col-md-12">
            <h1>SSM-CRUD</h1>
        </div>
    </div>
    <div class="row">
        <%--            功能按钮行--%>
        <div class="col-md-4 col-md-offset-10">
            <button  class="btn btn-primary" id="emp_add_modal_btn">新增</button>
            <button  class="btn btn-danger" id="emp_delete_all_btn">删除</button>
        </div>
    </div>

    <div class="row">
        <%--            显示表格数据--%>
        <div class="col-md-12">
            <table class="table table-hover" id="emps_table">
                <thead>
                    <tr>
                        <th>
                            <input type="checkbox" id="check_all">
                        </th>
                        <th>#</th>
                        <th>empName</th>
                        <th>gender</th>
                        <th>email</th>
                        <th>deptName</th>
                        <th>操作</th>
                    </tr>
                </thead>
               <tbody>

               </tbody>

            </table>
        </div>
    </div>
    <div class="row">
        <%--           显示分页信息 --%>
        <%--          分页文字信息  --%>
        <div class="col-md-6" id="page_info_area">

        </div>

        <%--           分页条信息--%>
        <div class="col-md-6" id="page_nav_area">


        </div>
    </div>
</div>


</body>
</html>
