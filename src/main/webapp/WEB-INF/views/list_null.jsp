<%--
  Created by IntelliJ IDEA.
  User: hy
  Date: 2022/3/20
  Time: 14:08
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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

    <script type="text/javascript" src="${APP_PATH}/ssm_demo/static/js/jquery-1.7.2.min.js"></script>
    <!-- Bootstrap -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css"
          integrity="sha384-HSMxcRTRxnN+Bdg0JdbxYKrThecOKuH5zCYotlSAcp1+c8xmyTe9GYg1l9a69psu"
          crossorigin="anonymous">

    <script src="https://stackpath.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"
            integrity="sha384-aJ21OjlMXNL5UyIl/XNwTMqvzeRMZH2w8c5cRVpzpU8Y5bApTppSuUkhZXN0VxHd"
            crossorigin="anonymous"></script>
</head>
<body>

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
            <button  class="btn btn-primary">新增</button>
            <button  class="btn btn-danger">删除</button>
        </div>
    </div>
    <div class="row">
        <%--            显示表格数据--%>
        <div class="col-md-12">
            <table class="table table-hover">
                <tr>
                    <th>#</th>
                    <th>empName</th>
                    <th>gender</th>
                    <th>email</th>
                    <th>deptName</th>
                    <th>操作</th>
                </tr>
                <tr>
                    <td>1</td>
                    <td>q</td>
                    <td>男</td>
                    <td>email</td>
                    <td>deptName</td>
                    <td>
                        <button class="btn btn-primary btn-sm">
                            <span class="glyphicon glyphicon-pencil " aria-hidden="true"></span>
                            编辑
                        </button>
                        <button class="btn btn-danger btn-sm">
                            <span class="glyphicon glyphicon-trash " aria-hidden="true"></span>
                            删除
                        </button>
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <div class="row">
        <%--           显示分页信息 --%>
        <%--          分页文字信息  --%>
        <div class="col-md-6">
            当前记录数:xxxx
        </div>

        <%--           分页条信息--%>
        <div class="col-md-6">
            <nav aria-label="Page navigation">
                <ul class="pagination">
                    <li>
                        <a href="#">首页</a>
                    </li>
                    <li>
                        <a href="#" aria-label="Previous">
                            <span aria-hidden="true">&laquo;</span>
                        </a>
                    </li>
                    <li><a href="#">1</a></li>
                    <li><a href="#">2</a></li>
                    <li><a href="#">3</a></li>
                    <li><a href="#">4</a></li>
                    <li><a href="#">5</a></li>
                    <li>
                        <a href="#" aria-label="Next">
                            <span aria-hidden="true">&raquo;</span>
                        </a>
                    </li>
                    <li>
                        <a href="#">末页</a>
                    </li>
                </ul>
            </nav>
        </div>
    </div>
</div>

</body>
</html>
