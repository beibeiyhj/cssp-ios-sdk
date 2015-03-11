一级标题（标题下面加：===）
==========================================
二级标题（标题下面加：---）
-------------------------------------
***
#一级标题（#）
##二级标题（##）
###三级标题（####）
####四级标题（####）
#####五级标题（#####）
######六级标题（######）
***
*斜体*（ \*内容\* 后必须空两格以上，才能换行）   

**粗体**（\**内容\** 后必须空两格以上，才能换行）   

***
用反引号`标记一小段行内代码`（\'内容\'）

> this is a block;(不能用)

***** 
无序（必须空一行才能正确显式列表）

* It fetures:
 * code management
 * HDFS Browser for hadoop

-------  
有序（必须空一行才能正确显式列表）

1. It fetures:
 1. code management
 2. HDFS Browser for hadoop

***
（引用址址：\[名字\]\(网址\)）   
[baidu](http://www.baidu.com) 

***
（引用图片:\!\[内容\]\(网址\)）  
![史努比](http://pic5.nipic.com/20100108/3838282_120913082385_2.jpg)

***
(代码块，用一个制表符或四个空格)

	if not path:
        try:
            git_operation(team_group, project, request.user, None, None)  #just may pull code
        except GitCommandError:
            messages.error(request, 'this repo haven been inited,\nplease push your existed repo!',
                           fail_silently=True)
            url = reverse('project_init_tip',
                          args=(team_group_name, project_name))
