import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/news_provider.dart';
import 'models/news_item.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NewsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open NUU',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'TW'),
        Locale('en', 'US'),
      ],
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1; // 預設選中首頁

  final List<Widget> _pages = [
    const ProfilePage(),
    const MainPage(),
    const MenuPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '個人資訊',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首頁',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu),
            selectedIcon: Icon(Icons.menu),
            label: '選單',
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('個人資訊'),
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            SizedBox(height: 16),
            Text('學生資訊'),
          ],
        ),
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open NUU'),
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '歡迎使用 Open NUU',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '開始使用您的應用程式',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('選單'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.calendar_month_outlined),
            title: Text('課表查詢'),
          ),
          const ListTile(
            leading: Icon(Icons.score_outlined),
            title: Text('成績查詢'),
          ),
          const ListTile(
            leading: Icon(Icons.event_note_outlined),
            title: Text('行事曆'),
          ),
          ListTile(
            leading: const Icon(Icons.campaign_outlined),
            title: const Text('校園公告'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CampusNewsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu_outlined),
            title: const Text('餐廳資訊'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RestaurantPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.departure_board_outlined),
            title: const Text('校車時刻'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BusSchedulePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CampusNewsPage extends StatefulWidget {
  const CampusNewsPage({Key? key}) : super(key: key);

  @override
  State<CampusNewsPage> createState() => _CampusNewsPageState();
}

class _CampusNewsPageState extends State<CampusNewsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 初始化時載入新聞
    Future.microtask(() {
      final newsProvider = context.read<NewsProvider>();
      newsProvider.refreshNews();
      newsProvider.startAutoRefresh();
    });

    // 添加滾動監聽
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      final newsProvider = context.read<NewsProvider>();
      if (!newsProvider.isLoading && newsProvider.hasMorePages) {
        newsProvider.loadMoreNews();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('校園公告'),
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: '聯大新聞'),
              Tab(text: '註冊組'),
              Tab(text: '獎助學金'),
              Tab(text: '徵人啟事'),
              Tab(text: '校園活動'),
            ],
            isScrollable: true,
          ),
        ),
        body: TabBarView(
          children: [
            _buildNewsTab('聯大新聞'),
            _buildNewsTab('註冊組'),
            _buildNewsTab('獎助學金'),
            _buildNewsTab('徵人啟事'),
            _buildNewsTab('校園活動'),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsTab(String category) {
    if (category == '聯大新聞') {
      return Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          if (newsProvider.isLoading && newsProvider.news.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (newsProvider.error != null && newsProvider.news.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(newsProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => newsProvider.refreshNews(),
                    child: const Text('重試'),
                  ),
                ],
              ),
            );
          }

          final news = newsProvider.news;
          if (news.isEmpty) {
            return const Center(child: Text('暫無新聞'));
          }

          return RefreshIndicator(
            onRefresh: () => newsProvider.refreshNews(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: news.length + (newsProvider.hasMorePages ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == news.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: newsProvider.isLoading
                          ? const CircularProgressIndicator()
                          : TextButton(
                              onPressed: () => newsProvider.loadMoreNews(),
                              child: const Text('載入更多'),
                            ),
                    ),
                  );
                }

                final newsItem = news[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsDetailPage(
                            title: newsItem.title,
                            category: newsItem.category,
                            newsItem: newsItem,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      getCategoryIcon(category),
                                      size: 16.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      category,
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                newsItem.date,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            newsItem.title,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            newsItem.description,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }
    return _buildDefaultNewsTab(category);
  }

  Widget _buildDefaultNewsTab(String category) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetailPage(
                    title: '${category}標題 ${index + 1}',
                    category: category,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              getCategoryIcon(category),
                              size: 16.0,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              category,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        '2024/03/${index + 1}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '${category}標題 ${index + 1}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    getDefaultDescription(category),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// 添加工具方法
IconData getCategoryIcon(String category) {
  switch (category) {
    case '聯大新聞':
      return Icons.newspaper;
    case '註冊組':
      return Icons.school;
    case '獎助學金':
      return Icons.attach_money;
    case '徵人啟事':
      return Icons.work;
    case '校園活動':
      return Icons.event;
    default:
      return Icons.article;
  }
}

String getDefaultDescription(String category) {
  switch (category) {
    case '聯大新聞':
      return '最新校園新聞與公告';
    case '註冊組':
      return '註冊相關事項與規定';
    case '獎助學金':
      return '獎助學金申請資訊';
    case '徵人啟事':
      return '校內外工作機會';
    case '校園活動':
      return '近期校園活動資訊';
    default:
      return '校園公告資訊';
  }
}

class NewsDetailPage extends StatelessWidget {
  final String title;
  final String category;
  final NewsItem? newsItem;

  const NewsDetailPage({
    Key? key,
    required this.title,
    required this.category,
    this.newsItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('公告詳情'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    getCategoryIcon(category),
                    size: 16.0,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    category,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '發布時間：${newsItem?.date ?? '2024/03/21'}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14.0,
              ),
            ),
            const Divider(height: 32.0),
            if (newsItem != null) ...[
              Text(
                newsItem!.content,
                style: const TextStyle(
                  fontSize: 16.0,
                  height: 1.6,
                ),
              ),
              if (newsItem!.imageUrl != null) ...[
                const SizedBox(height: 16.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    newsItem!.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              if (newsItem!.attachments != null) ...[
                const SizedBox(height: 16.0),
                const Text(
                  '附件檔案',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                ...newsItem!.attachments!.map((attachment) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.attach_file),
                    title: Text(attachment),
                    trailing: const Icon(Icons.download),
                    onTap: () {
                      // 處理檔案下載
                    },
                  ),
                )).toList(),
              ],
              if (newsItem!.link != null) ...[
                const SizedBox(height: 16.0),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.link),
                    title: const Text('相關連結'),
                    subtitle: Text(newsItem!.link!),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      // 處理連結開啟
                    },
                  ),
                ),
              ],
            ] else
              const Text(
                '這是公告的詳細內容...\n\n'
                '可以包含多個段落的文字說明...\n\n'
                '也可以包含連結和附件...',
                style: TextStyle(
                  fontSize: 16.0,
                  height: 1.6,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RestaurantPage extends StatelessWidget {
  const RestaurantPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('餐廳資訊'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '請選擇校區',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildCampusCard(
              context,
              '二坪山校區',
              Icons.location_city,
              const ErpingRestaurantPage(),
            ),
            const SizedBox(height: 16),
            _buildCampusCard(
              context,
              '八甲校區',
              Icons.apartment,
              const BajiaRestaurantPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampusCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '點擊查看詳細資訊',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErpingRestaurantPage extends StatelessWidget {
  const ErpingRestaurantPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('二坪山校區餐廳'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ErpingStudentRestaurantPage()),
              );
            },
            child: _buildRestaurantCard(
              '二坪學生餐廳',
              '位於紅夢樓一樓',
              [
                '營業時間：',
                '週一至週日',
                '早餐 06:30-13:00',
                '午餐 11:00-13:00',
                '晚餐 16:50-19:00',
                '',
                '點擊查看店家詳細資訊',
              ],
              Icons.restaurant,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LandscapeRestaurantPage()),
              );
            },
            child: _buildRestaurantCard(
              '景觀餐廳',
              '位於好漢坡旁',
              '營業時間：週一至週日 10:00-20:00\n點擊查看店家詳細資訊',
              Icons.food_bank,
            ),
          ),
          _buildRestaurantCard(
            '二坪 7-11',
            '位於操場旁、建築一館 1 F',
            '營業時間：週一至週日 07:00-23:00',
            Icons.store,
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(
    String title,
    String location,
    dynamic hours,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              location,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            if (hours is String)
              Text(
                hours,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              )
            else if (hours is List<String>)
              ...hours.map((line) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      line,
                      style: TextStyle(
                        fontSize: 14,
                        color: line.endsWith('：') ? Colors.black87 : Colors.black54,
                        fontWeight: line.endsWith('：') ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class ErpingStudentRestaurantPage extends StatelessWidget {
  const ErpingStudentRestaurantPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('二坪學生餐廳'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildShopCard(
            '巧麟中西式早餐店',
            [
              '位置：紅夢樓一樓',
              '營業時間：',
              '週一至週日 06:30-13:00',
              '假日 07：00－10：30',
              '主打特色：',
              '漢堡、三明治、蛋餅',
              '麵食、飯類、咖啡、奶茶',
            ],
            Icons.breakfast_dining,
            const ['assets/images/menu_qiaolin_1.jpg', 'assets/images/menu_qiaolin_2.jpg'],
          ),
          _buildShopCard(
            '蓮莊餐飲',
            [
              '位置：紅夢樓一樓',
              '營業時間：',
              '週一至週日',
              '午餐 11:00-13:30',
              '晚餐 16:50-18:30',
              '',
              '主打特色：',
              '快餐、炒飯(麵)及麵食',
            ],
            Icons.lunch_dining,
            const ['assets/images/menu_lianzhuang_1.jpg'],
          ),
          _buildShopCard(
            '小食堂滷味&飲品',
            [
              '位置：紅夢樓一樓',
              '營業時間：',
              '週一至週日 10:00-19:00',
              '',
              '主打特色：',
              '各式滷味、手工粉圓',
            ],
            Icons.soup_kitchen,
          ),
          _buildShopCard(
            '荷香園-麵麵聚到',
            [
              '位置：紅夢樓一樓',
              '營業時間：',
              '週一至週日',
              '午餐 11:00-13:30',
              '晚餐 16:50-18:30',
              '',
              '主打特色：',
              '各式麵食、湯麵',
            ],
            Icons.ramen_dining,
          ),
          _buildShopCard(
            '凍心炸冰淇淋',
            [
              '位置：紅夢樓一樓',
              '營業時間：',
              '週一至週日 11:00-18:00',
              '',
              '主打特色：',
              '炸冰淇淋、氣泡飲',
            ],
            Icons.icecream,
          ),
          _buildShopCard(
            '愛在蔬食',
            [
              '位置：紅夢樓一樓',
              '營業時間：',
              '週一至週日',
              '午餐 11:00-13:30',
              '晚餐 16:50-18:30',
              '',
              '主打特色：',
              '蔬食自助餐、素食便當',
            ],
            Icons.eco,
            const ['assets/images/menu_vegan_1.jpg'],
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(String title, List<String> content, IconData icon, [List<String>? menuImages]) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: Colors.orange),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...content.map((line) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    line,
                    style: TextStyle(
                      fontSize: 14,
                      color: line.endsWith('：') ? Colors.black87 : Colors.black54,
                      fontWeight: line.endsWith('：') ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                )),
            if (menuImages != null) ...[
              const SizedBox(height: 16),
              const Text(
                '菜單預覽：',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: menuImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageViewPage(
                                imageUrl: menuImages[index],
                                title: '$title - 菜單 ${index + 1}',
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: menuImages[index],
                          child: Container(
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                menuImages[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LandscapeRestaurantPage extends StatelessWidget {
  const LandscapeRestaurantPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('景觀餐廳'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildShopCard(
            context,
            '石灶麻辣',
            [
              '位於景觀餐廳一樓後棟'
              '營業時間：',
              '週一至週日 10:00-20:00',
              '',
            ],
            Icons.whatshot,
            const ['assets/images/menu_shizao_1.jpg'],
          ),
          _buildShopCard(
            context,
            '彭爸麵食館',
            [
              '位於景觀餐廳二樓',
              '營業時間：',
              '週一至週六 午晚餐',
              '',
            ],
            Icons.ramen_dining,
            const ['assets/images/menu_pengba_1.jpg'],
          ),
          _buildShopCard(
            context,
            '星空下複合式餐飲',
            [
              '位於景觀餐廳 1 F',
              '營業時間：',
              '週一至週日 10:30-20:00',
              '**星期六公休',
            ],
            Icons.restaurant_menu,
            const ['assets/images/menu_starsky_1.jpg'],
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(
    BuildContext context,
    String title,
    List<String> content,
    IconData icon,
    List<String>? menuImages,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: Colors.orange),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...content.map((line) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    line,
                    style: TextStyle(
                      fontSize: 14,
                      color: line.endsWith('：') ? Colors.black87 : Colors.black54,
                      fontWeight: line.endsWith('：') ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                )),
            if (menuImages != null) ...[
              const SizedBox(height: 16),
              const Text(
                '菜單預覽：',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: menuImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageViewPage(
                                imageUrl: menuImages[index],
                                title: '$title - 菜單 ${index + 1}',
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: menuImages[index],
                          child: Container(
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                menuImages[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ImageViewPage extends StatelessWidget {
  final String imageUrl;
  final String title;

  const ImageViewPage({
    Key? key,
    required this.imageUrl,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: imageUrl,
            child: Image.asset(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class BajiaRestaurantPage extends StatelessWidget {
  const BajiaRestaurantPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('八甲校區餐廳'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildRestaurantCard(
            '八甲景觀餐廳 / 老八餐飲',
            '位於校門口往聯大湖方向',
            '營業時間：週一至週五 10:00-19:00',
            Icons.restaurant,
            const ['assets/images/menu_lao8_1.jpg'],
          ),
          _buildRestaurantCard(
            '八甲圓廳學餐',
            '位於圓廳、第六宿舍前面',
            '營業時間：週一至週五 07:00-19:00',
            Icons.restaurant_menu,
          ),
          _buildRestaurantCard(
            '八甲 7-11',
            '位於理工學院一館 1 F',
            '營業時間：週一至週五 07:00-20:00',
            Icons.store,
          ),
          _buildRestaurantCard(
            '鴻林書局',
            '位於共教會中棟 2F',
            '營業時間：週一至週五 10:00-17:00',
            Icons.local_cafe,
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(
    String title,
    String location,
    String hours,
    IconData icon, [
    List<String>? menuImages,
  ]) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(location),
            const SizedBox(height: 8),
            Text(hours),
            if (menuImages != null) ...[
              const SizedBox(height: 16),
              const Text(
                '菜單預覽：',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: menuImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageViewPage(
                                imageUrl: menuImages[index],
                                title: '$title - 菜單 ${index + 1}',
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: menuImages[index],
                          child: Container(
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                menuImages[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BusSchedulePage extends StatefulWidget {
  const BusSchedulePage({Key? key}) : super(key: key);

  @override
  State<BusSchedulePage> createState() => _BusSchedulePageState();
}

class _BusSchedulePageState extends State<BusSchedulePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _busImages = [
    'assets/images/bus_schedule_1.png',
    'assets/images/bus_schedule_2.png',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('校車時刻表'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: _busImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    child: Image.asset(
                      _busImages[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _busImages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: _currentPage > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
                Text('${_currentPage + 1} / ${_busImages.length}'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: _currentPage < _busImages.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
