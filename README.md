iphone-app
==========

# **开源中国社区 iPhone 客户端项目简析** #

*注：本文假设你已经有xcode4或以上的开发环境 (建议 Xcode 4.3)*

直接用双击 oschina.xcodeproj 文件启动 xcode 即可

**本项目采用 GPL 授权协议，欢迎大家在这个基础上进行改进，并与大家分享。**

下面将简单的解析下项目：

**1、AFNetwork** --- 通用网络库<br/>
**2、GCDiscreetNotificationView** --- 顶部弹出并会自动消失的通知栏<br/>
**3、Thread** --- 后台线程对象，处理后台发送带图片的动弹<br/>
**4、SoftwareGroup** --- 所有软件索引页以及软件分组页<br/>
**5、Friends** --- 好友列表页，包括粉丝与关注者<br/>
**6、Search** --- 搜索页<br/>
**7、Favorite** --- 收藏页<br/>
**8、MBHUD** --- 载入提示控件<br/>
**9、FTColor** --- 富文本显示控件<br/>
**10、EGOImageLoading** --- 异步图像控件<br/>
**11、User** --- 其他用户个人专页以及登陆用户专页<br/>
**12、Comment** --- 评论列表页以及发表评论页<br/>
**13、AsyncImg** --- 异步图像控件，总要用于列表中用户头像加载<br/>
**14、Setting** --- 登录，注销以及关于我们<br/>
**15、Profile** --- 动态页，发表留言，以及对话气泡<br/>
**16、News** --- 新闻，问答的列表以及所有类型的文章详情页<br/>
**17、Tweet** --- 动弹列表，发表动弹以及动弹详情<br/>
**18、Helper** --- 项目辅助类<br/>
**19、TBXML** --- xml解析，反序列化所有API返回的XML字符串<br/>
**20、ASIHttp** --- 另一种网络库，负责用户登陆以及发送带图片的动弹<br/>
**21、Model** --- 项目所有的实体对象<br/>
**22、Resource** --- 项目资源<br/>

下面是 Model 目录的子对象：
> Model<br>
> ├ Tweet 动弹列表单元，也用于动弹详情<br>
> ├ News 新闻列表单元<br>
> ├ Post 问答列表单元<br>
> ├ Message 留言列表单元<br>
> ├ Activity 动态列表单元<br>
> ├ Config 程序配置设置<br>
> ├ SingleNews 新闻详情<br>
> ├ SinglePostDetail 问答详情<br>
> └ Comment 评论列表单元<br>
> └ Software 软件详情<br>
> └ Blog 博客详情<br>
> └ Favorite 收藏列表单元<br>
> └ SearchResult 搜索结果列表单元<br>
> └ Friend 好友列表单元<br>
> └ SoftwareCatalog 软件分类列表单元<br>
> └ SoftwareUnit 软件列表单元<br>
> └ BlogUnit 博客列表单元<br>


## **项目的功能流程** ##

#### 1、APP启动流程 ####

OSAppDelegate 的启动方法中，声明一个 UITabBarController，然后依次将<br/>
NewsBase<br/>
PostBase<br/>
TweetBase2<br/>
ProfileBase<br/>
SettingView<br/>
填充到5个UITabItem里


#### 2、ipa文件生成流程 ####

1,在OSX系统上启动iTunes程序<br/>
2,启动Xcode，将项目中的 OSChina/Products/oschina.app 按住command键然后用鼠标拖放到iTunes的应用程序栏目<br/>
3,然后在iTunes程序中右键点击"开源中国"图标，在弹出的的菜单中选择"在Finder中显示"，这样你就看到ipa文件的路径了。

